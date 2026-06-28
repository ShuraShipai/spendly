import 'package:flutter/material.dart';

import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/welcome_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const welcome = '/';
  static const signUp = '/sign-up';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (_) => const WelcomeScreen(),
      signUp: (_) => const SignUpScreen(),
      login: (_) => const LoginScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      resetPassword: (_) => const ResetPasswordScreen(),
    };
  }
}
