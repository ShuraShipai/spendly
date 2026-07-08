import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/services/user_firestore_service.dart';
import '../features/expenses/providers/expense_provider.dart';
import '../features/expenses/services/custom_category_service.dart';
import '../features/expenses/services/expense_service.dart';
import '../features/home/providers/dashboard_period_provider.dart';
import '../features/reports/providers/reports_provider.dart';
import '../features/settings/providers/budget_alert_provider.dart';
import '../features/settings/providers/settings_provider.dart';
import '../features/settings/services/budget_local_notification_service.dart';
import '../features/settings/services/settings_firestore_service.dart';
import 'providers/app_state_provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => UserFirestoreService()),
        Provider(create: (_) => CustomCategoryService()),
        Provider(create: (_) => ExpenseService()),
        Provider(create: (_) => SettingsFirestoreService()),
        Provider(create: (_) => BudgetLocalNotificationService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            userFirestoreService: context.read<UserFirestoreService>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppStateProvider>(
          create: (context) => AppStateProvider(
            settingsService: context.read<SettingsFirestoreService>(),
          ),
          update: (_, authProvider, appStateProvider) {
            final provider =
                appStateProvider ??
                AppStateProvider(settingsService: SettingsFirestoreService());
            unawaited(provider.bindUser(authProvider.user?.uid));
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (context) =>
              ExpenseProvider(expenseService: context.read<ExpenseService>()),
          update: (_, authProvider, expenseProvider) {
            final provider =
                expenseProvider ??
                ExpenseProvider(expenseService: ExpenseService());
            provider.bindUser(authProvider.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => DashboardPeriodProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
          create: (context) => SettingsProvider(
            categoryService: context.read<CustomCategoryService>(),
            settingsService: context.read<SettingsFirestoreService>(),
          ),
          update: (_, authProvider, settingsProvider) {
            final provider =
                settingsProvider ??
                SettingsProvider(
                  categoryService: CustomCategoryService(),
                  settingsService: SettingsFirestoreService(),
                );
            unawaited(provider.bindUser(authProvider.user?.uid));
            return provider;
          },
        ),
        ProxyProvider<ExpenseProvider, ReportsProvider>(
          update: (_, expenseProvider, _) =>
              ReportsProvider(expenses: expenseProvider.expenses),
        ),
        ChangeNotifierProxyProvider3<
          AppStateProvider,
          ExpenseProvider,
          SettingsProvider,
          BudgetAlertProvider
        >(
          create: (context) => BudgetAlertProvider(
            localNotificationService: context
                .read<BudgetLocalNotificationService>(),
          ),
          update:
              (
                context,
                appStateProvider,
                expenseProvider,
                settingsProvider,
                alerts,
              ) {
                final provider = alerts ?? BudgetAlertProvider();
                provider.updateAlerts(
                  alertsEnabled: appStateProvider.budgetAlertsEnabled,
                  expenseProvider: expenseProvider,
                  settingsProvider: settingsProvider,
                );
                return provider;
              },
        ),
      ],
      child: child,
    );
  }
}
