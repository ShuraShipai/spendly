import 'package:flutter/material.dart';

import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/budget_alert_provider.dart';
import '../providers/settings_provider.dart';
import 'budget_notifications_list.dart';
import 'notifications_empty_state.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({
    required this.appState,
    required this.alertsProvider,
    required this.settingsProvider,
    required this.onNotificationTap,
    super.key,
  });

  final AppStateProvider appState;
  final BudgetAlertProvider alertsProvider;
  final SettingsProvider settingsProvider;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final notifications = alertsProvider.activeAlerts;
    final isLoading =
        settingsProvider.isLoadingBudget ||
        settingsProvider.isLoadingCategories;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (isLoading) ...[
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: AppSpacing.md),
          ],
          if (!appState.budgetAlertsEnabled)
            NotificationsEmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'Budget alerts are off',
              message: 'Turn them on in Settings to see budget warnings.',
            )
          else if (notifications.isEmpty)
            const NotificationsEmptyState(
              icon: Icons.check_rounded,
              title: 'No budget alerts',
              message: 'You are within your category budgets this month.',
            )
          else
            BudgetNotificationsList(
              notifications: notifications,
              onNotificationTap: onNotificationTap,
            ),
        ],
      ),
    );
  }
}
