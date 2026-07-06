import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/budget_notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? _loadedUserId;
  var _hasRequestedSettings = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().user?.uid;
    if (_hasRequestedSettings && _loadedUserId == uid) {
      return;
    }

    _hasRequestedSettings = true;
    _loadedUserId = uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final settingsProvider = context.read<SettingsProvider>();
      unawaited(settingsProvider.loadCategories(uid));
      unawaited(settingsProvider.loadBudget(uid));
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final notifications = _budgetNotifications(
      settingsProvider: settingsProvider,
      expenseProvider: expenseProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            if (settingsProvider.isLoadingBudget ||
                settingsProvider.isLoadingCategories) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: AppSpacing.md),
            ],
            if (!appState.budgetAlertsEnabled)
              _NotificationsEmptyState(
                icon: Icons.notifications_off_rounded,
                title: 'Budget alerts are off',
                message: 'Turn them on in Settings to see budget warnings.',
              )
            else if (notifications.isEmpty)
              const _NotificationsEmptyState(
                icon: Icons.check_rounded,
                title: 'No budget alerts',
                message: 'You are within your category budgets this month.',
              )
            else
              Column(
                children: [
                  for (
                    var index = 0;
                    index < notifications.length;
                    index++
                  ) ...[
                    BudgetNotificationTile(
                      severity: notifications[index].severity,
                      title: notifications[index].title,
                      message: notifications[index].message,
                      timeLabel: notifications[index].timeLabel,
                      isUnread: notifications[index].isUnread,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.categoryBudgets),
                    ),
                    if (index != notifications.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<_BudgetNotification> _budgetNotifications({
    required SettingsProvider settingsProvider,
    required ExpenseProvider expenseProvider,
  }) {
    final notifications = <_BudgetNotification>[];
    final month = DateTime.now();
    final monthExpenses = expenseProvider.expensesForMonth(month);
    final totalSpent = monthExpenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );

    if (settingsProvider.monthlyBudget > 0) {
      final progress = totalSpent / settingsProvider.monthlyBudget;
      if (progress >= 0.8) {
        notifications.add(
          progress > 1
              ? _BudgetNotification.overallExceeded(
                  spent: totalSpent,
                  budget: settingsProvider.monthlyBudget,
                )
              : _BudgetNotification.overallWarning(
                  spent: totalSpent,
                  budget: settingsProvider.monthlyBudget,
                  percent: (progress * 100).round(),
                ),
        );
      }
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

      if (progress >= 0.8) {
        notifications.add(
          progress > 1
              ? _BudgetNotification.categoryExceeded(
                  category: category,
                  overAmount: spent - budget,
                )
              : _BudgetNotification.categoryWarning(
                  category: category,
                  spent: spent,
                  budget: budget,
                  percent: (progress * 100).round(),
                ),
        );
      }
    }

    notifications.sort((a, b) => a.sortPriority.compareTo(b.sortPriority));
    return notifications;
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: (isDark ? AppColors.darkInkMuted : AppColors.line).withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.mintTint,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: SizedBox.square(
                dimension: 72,
                child: Icon(icon, color: AppColors.mintDark, size: 34),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetNotification {
  const _BudgetNotification({
    required this.severity,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.sortPriority,
    this.isUnread = false,
  });

  factory _BudgetNotification.overallExceeded({
    required double spent,
    required double budget,
  }) {
    return _BudgetNotification(
      severity: BudgetNotificationSeverity.exceeded,
      title: 'Monthly budget exceeded',
      message:
          'You are ${_formatAmount(spent - budget)} over your monthly budget.',
      timeLabel: 'This month',
      sortPriority: 0,
      isUnread: true,
    );
  }

  factory _BudgetNotification.overallWarning({
    required double spent,
    required double budget,
    required int percent,
  }) {
    return _BudgetNotification(
      severity: BudgetNotificationSeverity.warning,
      title: '$percent% of monthly budget used',
      message: '${_formatAmount(spent)} of ${_formatAmount(budget)} spent.',
      timeLabel: 'This month',
      sortPriority: 1,
    );
  }

  factory _BudgetNotification.categoryExceeded({
    required ExpenseCategory category,
    required double overAmount,
  }) {
    return _BudgetNotification(
      severity: BudgetNotificationSeverity.exceeded,
      title: 'Budget exceeded',
      message: '${category.label} is ${_formatAmount(overAmount)} over budget.',
      timeLabel: 'This month',
      sortPriority: 2,
      isUnread: true,
    );
  }

  factory _BudgetNotification.categoryWarning({
    required ExpenseCategory category,
    required double spent,
    required double budget,
    required int percent,
  }) {
    return _BudgetNotification(
      severity: BudgetNotificationSeverity.warning,
      title: '$percent% of ${category.label} budget used',
      message: '${_formatAmount(spent)} of ${_formatAmount(budget)} spent.',
      timeLabel: 'This month',
      sortPriority: 3,
    );
  }

  final BudgetNotificationSeverity severity;
  final String title;
  final String message;
  final String timeLabel;
  final int sortPriority;
  final bool isUnread;

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}
