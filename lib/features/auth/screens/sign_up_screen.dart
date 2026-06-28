import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_bar.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      bottom: Column(
        children: [
          AppPrimaryButton(label: 'Create account', onPressed: () {}),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.login),
            child: Text.rich(
              TextSpan(
                text: 'Already a member? ',
                style: Theme.of(context).textTheme.bodySmall,
                children: const [
                  TextSpan(
                    text: 'Log in',
                    style: TextStyle(
                      color: AppColors.mintDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        children: const [
          AuthHeader(
            title: 'Create account',
            subtitle: 'Start tracking in under a minute',
          ),
          SizedBox(height: AppSpacing.xl),
          AppTextField(label: 'Name (optional)', initialValue: 'Aanya Sharma'),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            initialValue: 'aanya@email.com',
            keyboardType: TextInputType.emailAddress,
            focused: true,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            initialValue: 'password',
            obscureText: true,
            trailing: Icon(
              Icons.visibility_outlined,
              color: AppColors.inkSubtle,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          PasswordStrengthBar(label: 'Strong', activeSegments: 3),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Confirm password',
            initialValue: 'password',
            obscureText: true,
            trailing: Icon(Icons.check_rounded, color: Color(0xFF68BF5E)),
          ),
        ],
      ),
    );
  }
}
