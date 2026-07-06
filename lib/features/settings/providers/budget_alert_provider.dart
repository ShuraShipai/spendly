import 'package:flutter/foundation.dart';

import '../../expenses/models/expense_category.dart';
import '../../expenses/providers/expense_provider.dart';
import 'settings_provider.dart';

enum BudgetAlertSeverity { warning, exceeded }

enum BudgetExceededAlertType { overall, category }

class BudgetExceededAlert {
  const BudgetExceededAlert({
    required this.id,
    required this.severity,
    required this.type,
    required this.title,
    required this.message,
    required this.spent,
    required this.budget,
    this.category,
  });

  final String id;
  final BudgetAlertSeverity severity;
  final BudgetExceededAlertType type;
  final String title;
  final String message;
  final double spent;
  final double budget;
  final ExpenseCategory? category;

  double get overAmount => spent - budget;
}

class BudgetAlertProvider extends ChangeNotifier {
  final List<BudgetExceededAlert> _pendingAlerts = [];
  final Set<String> _seenAlertStates = {};

  BudgetExceededAlert? get pendingAlert {
    return _pendingAlerts.isEmpty ? null : _pendingAlerts.first;
  }

  void updateAlerts({
    required bool alertsEnabled,
    required ExpenseProvider expenseProvider,
    required SettingsProvider settingsProvider,
    DateTime? referenceDate,
  }) {
    if (!alertsEnabled || settingsProvider.isLoadingBudget) {
      _clearPendingAlerts();
      return;
    }

    final month = _monthKey(referenceDate ?? DateTime.now());
    final monthExpenses = expenseProvider.expensesForMonth(
      referenceDate ?? DateTime.now(),
    );
    final totalSpent = monthExpenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
    final nextAlerts = <BudgetExceededAlert>[];

    if (settingsProvider.monthlyBudget > 0 &&
        totalSpent >= settingsProvider.monthlyBudget * 0.8) {
      final id = _stateId(
        month: month,
        type: BudgetExceededAlertType.overall,
        severity: totalSpent > settingsProvider.monthlyBudget
            ? BudgetAlertSeverity.exceeded
            : BudgetAlertSeverity.warning,
        budget: settingsProvider.monthlyBudget,
      );
      nextAlerts.add(
        BudgetExceededAlert(
          id: id,
          severity: totalSpent > settingsProvider.monthlyBudget
              ? BudgetAlertSeverity.exceeded
              : BudgetAlertSeverity.warning,
          type: BudgetExceededAlertType.overall,
          title: totalSpent > settingsProvider.monthlyBudget
              ? 'Monthly budget exceeded'
              : 'Monthly budget warning',
          message: totalSpent > settingsProvider.monthlyBudget
              ? 'You are ${_formatAmount(totalSpent - settingsProvider.monthlyBudget)} over your monthly budget.'
              : 'You have used ${_formatPercent(totalSpent / settingsProvider.monthlyBudget)} of your monthly budget.',
          spent: totalSpent,
          budget: settingsProvider.monthlyBudget,
        ),
      );
    }

    for (final category in settingsProvider.categories) {
      final budget = settingsProvider.budgetForCategory(category.id);
      if (budget <= 0) {
        continue;
      }

      final spent = monthExpenses
          .where((expense) => expense.category.id == category.id)
          .fold<double>(0, (total, expense) => total + expense.amount);
      final progress = spent / budget;
      if (progress < 0.8) {
        continue;
      }

      final id = _stateId(
        month: month,
        type: BudgetExceededAlertType.category,
        severity: spent > budget
            ? BudgetAlertSeverity.exceeded
            : BudgetAlertSeverity.warning,
        categoryId: category.id,
        budget: budget,
      );
      nextAlerts.add(
        BudgetExceededAlert(
          id: id,
          severity: spent > budget
              ? BudgetAlertSeverity.exceeded
              : BudgetAlertSeverity.warning,
          type: BudgetExceededAlertType.category,
          title: spent > budget
              ? '${category.label} budget exceeded'
              : '${category.label} budget warning',
          message: spent > budget
              ? '${category.label} is ${_formatAmount(spent - budget)} over its budget.'
              : '${category.label} is ${_formatPercent(progress)} of its budget.',
          spent: spent,
          budget: budget,
          category: category,
        ),
      );
    }

    final activeIds = nextAlerts.map((alert) => alert.id).toSet();
    _seenAlertStates.removeWhere((id) => !activeIds.contains(id));

    final filteredAlerts = nextAlerts
        .where((alert) => !_seenAlertStates.contains(alert.id))
        .toList(growable: false);
    if (_sameQueue(filteredAlerts)) {
      return;
    }

    _pendingAlerts
      ..clear()
      ..addAll(filteredAlerts);
    notifyListeners();
  }

  void markAlertShown(String alertId) {
    final wasPending = _pendingAlerts.any((alert) => alert.id == alertId);
    final wasSeen = _seenAlertStates.contains(alertId);
    if (!wasPending && wasSeen) {
      return;
    }

    _pendingAlerts.removeWhere((alert) => alert.id == alertId);
    _seenAlertStates.add(alertId);
    notifyListeners();
  }

  void _clearPendingAlerts() {
    if (_pendingAlerts.isEmpty) {
      return;
    }
    _pendingAlerts.clear();
    notifyListeners();
  }

  bool _sameQueue(List<BudgetExceededAlert> alerts) {
    if (_pendingAlerts.length != alerts.length) {
      return false;
    }

    for (var index = 0; index < alerts.length; index++) {
      if (_pendingAlerts[index].id != alerts[index].id) {
        return false;
      }
    }
    return true;
  }

  String _stateId({
    required String month,
    required BudgetExceededAlertType type,
    required BudgetAlertSeverity severity,
    required double budget,
    String? categoryId,
  }) {
    final budgetCents = (budget * 100).round();
    return '$month:${type.name}:${severity.name}:${categoryId ?? 'overall'}:$budgetCents';
  }

  String _monthKey(DateTime date) {
    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    return '${localDate.year}-$month';
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }
}
