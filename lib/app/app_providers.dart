import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/services/user_firestore_service.dart';
import '../features/expenses/providers/expense_provider.dart';
import '../features/expenses/services/custom_category_service.dart';
import '../features/home/providers/dashboard_period_provider.dart';
import '../features/reports/providers/reports_provider.dart';
import '../features/settings/providers/settings_provider.dart';
import 'providers/app_state_provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ProxyProvider<ExpenseProvider, ReportsProvider>(
          update: (_, expenseProvider, _) =>
              ReportsProvider(expenses: expenseProvider.expenses),
        ),
        ChangeNotifierProvider(create: (_) => DashboardPeriodProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => UserFirestoreService()),
        Provider(create: (_) => CustomCategoryService()),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(
            categoryService: context.read<CustomCategoryService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            userFirestoreService: context.read<UserFirestoreService>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
