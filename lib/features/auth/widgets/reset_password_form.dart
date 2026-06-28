import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../constants/auth_validators.dart';
import '../providers/auth_provider.dart';
import 'auth_error_banner.dart';
import 'auth_icon_panel.dart';
import 'auth_password_field.dart';
import 'password_strength_bar.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({required this.resetCode, super.key});

  final String? resetCode;

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordReset = false;

  bool get _hasResetCode => widget.resetCode?.isNotEmpty ?? false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.read<AuthProvider>().clearError();
    if (!_hasResetCode || !_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthProvider>().resetPassword(
      code: widget.resetCode!,
      newPassword: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (context.read<AuthProvider>().errorMessage == null) {
      setState(() => _passwordReset = true);
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
            child: ListView(
              padding: const EdgeInsets.only(top: AppSpacing.xxxl),
              children: [
                const AuthIconPanel(icon: Icons.lock_outline_rounded, size: 76),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _passwordReset ? 'Password updated' : 'Set a new password',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _hasResetCode
                      ? 'Make it at least 8 characters with a letter and a number.'
                      : 'Open this screen from a valid Firebase reset link.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AuthErrorBanner(message: authProvider.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.xl),
                AuthPasswordField(
                  label: 'New password',
                  controller: _passwordController,
                  validator: AuthValidators.password,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: AppSpacing.xs),
                PasswordStrengthBar(controller: _passwordController),
                const SizedBox(height: AppSpacing.md),
                AuthPasswordField(
                  label: 'Confirm password',
                  controller: _confirmPasswordController,
                  validator: (value) => AuthValidators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.newPassword],
                ),
              ],
            ),
          ),
        ),
        AppPrimaryButton(
          label: _passwordReset ? 'Password reset' : 'Reset password',
          isLoading: authProvider.isLoading,
          onPressed: authProvider.isLoading || !_hasResetCode ? null : _submit,
        ),
      ],
    );
  }
}
