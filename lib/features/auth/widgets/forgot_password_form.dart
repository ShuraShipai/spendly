import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../constants/auth_validators.dart';
import '../providers/auth_provider.dart';
import 'auth_error_banner.dart';
import 'auth_icon_panel.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.read<AuthProvider>().clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthProvider>().sendPasswordResetEmail(
      _emailController.text,
    );

    if (!mounted) {
      return;
    }

    if (context.read<AuthProvider>().errorMessage == null) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthIconPanel(icon: Icons.mail_outline_rounded),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  _emailSent ? 'Check your inbox' : 'Forgot password?',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _emailSent
                      ? 'We sent a reset link to your email address.'
                      : "No worries, enter your email and we'll send a reset link.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AuthErrorBanner(message: authProvider.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.email],
                  focused: true,
                ),
              ],
            ),
          ),
        ),
        AppPrimaryButton(
          label: _emailSent ? 'Send again' : 'Send reset link',
          isLoading: authProvider.isLoading,
          onPressed: authProvider.isLoading ? null : _submit,
        ),
      ],
    );
  }
}
