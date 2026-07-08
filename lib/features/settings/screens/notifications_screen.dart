import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/budget_alert_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/budget_notifications_list.dart';
import '../widgets/notifications_empty_state.dart';

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
                onNotificationTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.categoryBudgets),
              ),
          ],
        ),
      ),
    );
  }
}
