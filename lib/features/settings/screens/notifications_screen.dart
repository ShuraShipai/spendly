import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/budget_alert_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/notifications_body.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: NotificationsBody(
        appState: appState,
        alertsProvider: alertsProvider,
        settingsProvider: settingsProvider,
        onNotificationTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.categoryBudgets),
      ),
    );
  }
}
