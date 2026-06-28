import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../constants/auth_validators.dart';
import '../providers/auth_provider.dart';
import 'auth_error_banner.dart';
import 'auth_password_field.dart';
import 'penny_mark.dart';
import 'remember_me_row.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.read<AuthProvider>().clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthProvider>().login(
      email: _emailController.text,
      password: _passwordController.text,
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
              padding: const EdgeInsets.only(top: AppSpacing.xxxl),
              children: [
                const Center(child: PennyMark(size: 76)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Log in to keep tracking',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AuthErrorBanner(message: authProvider.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.md),
                AuthPasswordField(
                  label: 'Password',
                  controller: _passwordController,
                  validator: AuthValidators.password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.password],
                ),
                const SizedBox(height: AppSpacing.sm),
                RememberMeRow(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value);
                  },
                ),
              ],
            ),
          ),
        ),
        AppPrimaryButton(
          label: 'Log in',
          isLoading: authProvider.isLoading,
          onPressed: authProvider.isLoading ? null : _submit,
        ),
      ],
    );
  }
}
