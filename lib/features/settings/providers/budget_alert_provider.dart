import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../expenses/models/expense_category.dart';
import '../../expenses/providers/expense_provider.dart';
import '../services/budget_local_notification_service.dart';
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
  BudgetAlertProvider({this.localNotificationService});

  final BudgetLocalNotificationService? localNotificationService;
  final List<BudgetExceededAlert> _pendingAlerts = [];
  final Set<String> _seenAlertStates = {};
  final Set<String> _deliveredNotificationStates = {};

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
      final id = _stateId(month: month, type: BudgetExceededAlertType.overall);
      final progress = totalSpent / settingsProvider.monthlyBudget;
      nextAlerts.add(
        BudgetExceededAlert(
          id: id,
          severity: totalSpent > settingsProvider.monthlyBudget
              ? BudgetAlertSeverity.exceeded
              : BudgetAlertSeverity.warning,
          type: BudgetExceededAlertType.overall,
          title: 'Heads up — ${_formatPercent(progress)} used',
          message:
              'You\'ve spent ${_formatAmount(totalSpent)} of your ${_formatAmount(settingsProvider.monthlyBudget)} Overall budget this month.',
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
        categoryId: category.id,
      );
      nextAlerts.add(
        BudgetExceededAlert(
          id: id,
          severity: spent > budget
              ? BudgetAlertSeverity.exceeded
              : BudgetAlertSeverity.warning,
          type: BudgetExceededAlertType.category,
          title: 'Heads up — ${_formatPercent(progress)} used',
          message:
              'You\'ve spent ${_formatAmount(spent)} of your ${_formatAmount(budget)} ${category.label} budget this month.',
          spent: spent,
          budget: budget,
          category: category,
        ),
      );
    }

    final activeIds = nextAlerts.map((alert) => alert.id).toSet();
    _seenAlertStates.removeWhere((id) => !activeIds.contains(id));
    _deliveredNotificationStates.removeWhere((id) => !activeIds.contains(id));

    for (final alert in nextAlerts) {
      if (_deliveredNotificationStates.add(alert.id)) {
        unawaited(_showLocalNotification(alert));
      }
    }

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

  Future<void> _showLocalNotification(BudgetExceededAlert alert) async {
    final service = localNotificationService;
    if (service == null) {
      return;
    }

    try {
      await service.showBudgetThresholdAlert(
        id: alert.id,
        title: alert.title,
        body: alert.message,
      );
    } on Object {
      // Budget alerts must not break provider updates if the OS denies or
      // fails to display a local notification.
    }
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
    String? categoryId,
  }) {
    return '$month:${type.name}:${categoryId ?? 'overall'}';
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
