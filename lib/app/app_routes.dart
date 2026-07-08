import 'package:flutter/material.dart';

import '../features/auth/screens/auth_gate.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/expenses/screens/edit_expense_screen.dart';
import '../features/expenses/screens/expense_detail_screen.dart';
import '../features/settings/models/budget_editor_request.dart';
import '../features/settings/screens/categories_screen.dart';
import '../features/settings/screens/category_budgets_screen.dart';
import '../features/settings/screens/notifications_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import 'main_navigation_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const authGate = '/';
  static const welcome = '/welcome';
  static const signUp = '/sign-up';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const settings = '/settings';
  static const categories = '/settings/categories';
  static const categoryBudgets = '/settings/category-budgets';
  static const notifications = '/settings/notifications';
  static const expenseDetail = '/expenses/detail';
  static const editExpense = '/expenses/edit';

  static Map<String, WidgetBuilder> get routes {
    return {
      authGate: (_) =>
          const AuthGate(authenticatedBuilder: _buildAuthenticatedScreen),
      welcome: (_) => const WelcomeScreen(),
      signUp: (_) => const SignUpScreen(),
      login: (_) => const LoginScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      resetPassword: (_) => const ResetPasswordScreen(),
      home: (_) => const MainNavigationScreen(),
      settings: (_) => const Scaffold(body: SettingsScreen()),
      categories: (_) => const CategoriesScreen(),
      notifications: (_) => const NotificationsScreen(),
    };
  }

  static Widget _buildAuthenticatedScreen(BuildContext context) {
    return const MainNavigationScreen();
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) {
      return null;
    }

    final uri = Uri.parse(name);
    if (uri.path == resetPassword) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            ResetPasswordScreen(resetCode: uri.queryParameters['oobCode']),
      );
    }

    if (uri.path == categoryBudgets) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CategoryBudgetsScreen(
          initialEditorRequest: _budgetEditorRequestFrom(settings),
        ),
      );
    }

    if (uri.path == expenseDetail) {
      final expenseId = _expenseIdFrom(settings);
      if (expenseId == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ExpenseDetailScreen(expenseId: expenseId),
      );
    }

    if (uri.path == editExpense) {
      final expenseId = _expenseIdFrom(settings);
      if (expenseId == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => EditExpenseScreen(expenseId: expenseId),
      );
    }

    return null;
  }

  static String? _expenseIdFrom(RouteSettings settings) {
    final arguments = settings.arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return arguments;
    }

    return null;
  }

  static BudgetEditorRequest? _budgetEditorRequestFrom(RouteSettings settings) {
    final arguments = settings.arguments;
    if (arguments is BudgetEditorRequest) {
      return arguments;
    }

    return null;
  }
}
