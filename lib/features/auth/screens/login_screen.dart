import 'package:flutter/material.dart';

import '../widgets/auth_scaffold.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(child: LoginForm());
  }
}
