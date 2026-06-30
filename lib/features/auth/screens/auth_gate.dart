import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/screens/main_navigation_screen.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return switch (authProvider.status) {
      AuthStatus.unknown => const _AuthLoadingScreen(),
      AuthStatus.unauthenticated => const WelcomeScreen(),
      AuthStatus.authenticated => const MainNavigationScreen(),
    };
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.mint)),
    );
  }
}
