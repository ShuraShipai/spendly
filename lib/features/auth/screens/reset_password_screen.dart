import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_bar.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      bottom: AppPrimaryButton(label: 'Reset password', onPressed: () {}),
      child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.mintDark,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Set a new password',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Make it at least 8 characters with a letter and a number.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppTextField(
            label: 'New password',
            initialValue: 'newpassword',
            obscureText: true,
            trailing: Icon(
              Icons.visibility_outlined,
              color: AppColors.inkSubtle,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const PasswordStrengthBar(
            label: 'Good',
            activeSegments: 3,
            warning: true,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppTextField(
            label: 'Confirm password',
            initialValue: 'newpassword',
            obscureText: true,
            trailing: Icon(Icons.check_rounded, color: Color(0xFF68BF5E)),
          ),
        ],
      ),
    );
  }
}
