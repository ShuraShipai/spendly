import 'package:flutter/material.dart';

import '../features/auth/screens/auth_gate.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/home/screens/main_navigation_screen.dart';
import '../features/settings/screens/settings_screen.dart';

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

  static Map<String, WidgetBuilder> get routes {
    return {
      authGate: (_) => const AuthGate(),
      welcome: (_) => const WelcomeScreen(),
      signUp: (_) => const SignUpScreen(),
      login: (_) => const LoginScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      resetPassword: (_) => const ResetPasswordScreen(),
      home: (_) => const MainNavigationScreen(),
      settings: (_) => const SettingsScreen(),
    };
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

    return null;
  }
}
