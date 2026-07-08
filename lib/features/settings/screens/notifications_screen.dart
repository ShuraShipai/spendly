import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/budget_alert_provider.dart';
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
    final alertsProvider = context.watch<BudgetAlertProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final notifications = alertsProvider.activeAlerts;

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
                      severity: _tileSeverityFor(notifications[index].severity),
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

  BudgetNotificationSeverity _tileSeverityFor(BudgetAlertSeverity severity) {
    return switch (severity) {
      BudgetAlertSeverity.exceeded => BudgetNotificationSeverity.exceeded,
      BudgetAlertSeverity.warning => BudgetNotificationSeverity.warning,
    };
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
