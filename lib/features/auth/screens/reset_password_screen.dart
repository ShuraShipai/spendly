import 'package:flutter/material.dart';

import '../widgets/auth_scaffold.dart';
import '../widgets/reset_password_form.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({this.resetCode, super.key});

  final String? resetCode;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final code = resetCode ?? (args is String ? args : null);

    return AuthScaffold(child: ResetPasswordForm(resetCode: code));
  }
}
