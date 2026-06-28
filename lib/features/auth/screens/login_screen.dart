import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/penny_mark.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      bottom: AppPrimaryButton(label: 'Log in', onPressed: () {}),
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
          const SizedBox(height: AppSpacing.xl),
          const AuthErrorBanner(message: 'Email or password is incorrect'),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Email',
            initialValue: 'aanya@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Password',
            initialValue: 'secret',
            obscureText: true,
            errorText: '',
            trailing: Icon(
              Icons.visibility_outlined,
              color: AppColors.inkSubtle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Remember me',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                child: const Text('Forgot?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
