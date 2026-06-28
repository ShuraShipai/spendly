import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/services/user_firestore_service.dart';
import 'providers/app_state_provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => UserFirestoreService()),
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
