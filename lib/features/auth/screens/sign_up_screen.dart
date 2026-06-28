import 'package:flutter/material.dart';

import '../widgets/auth_scaffold.dart';
import '../widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(child: SignUpForm());
  }
}
