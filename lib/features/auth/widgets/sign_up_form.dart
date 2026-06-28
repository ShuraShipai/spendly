import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../constants/auth_validators.dart';
import '../providers/auth_provider.dart';
import 'auth_error_banner.dart';
import 'auth_footer_link.dart';
import 'auth_header.dart';
import 'auth_password_field.dart';
import 'password_strength_bar.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.read<AuthProvider>().clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthProvider>().signUp(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController.text,
    );

    if (!mounted) {
      return;
    }

    if (context.read<AuthProvider>().errorMessage == null) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.authGate, (_) => false);
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
              padding: const EdgeInsets.only(top: AppSpacing.xxl),
              children: [
                const AuthHeader(
                  title: 'Create account',
                  subtitle: 'Start tracking in under a minute',
                ),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AuthErrorBanner(message: authProvider.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Name',
                  controller: _nameController,
                  validator: AuthValidators.displayName,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  focused: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AuthPasswordField(
                  label: 'Password',
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
          label: 'Create account',
          isLoading: authProvider.isLoading,
          onPressed: authProvider.isLoading ? null : _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        AuthFooterLink(
          text: 'Already a member?',
          actionText: 'Log in',
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        ),
      ],
    );
  }
}
