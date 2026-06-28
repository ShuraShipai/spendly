import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/penny_mark.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [AppColors.mintTint, AppColors.background],
        ),
      ),
      child: AuthScaffold(
        bottom: Column(
          children: [
            AppPrimaryButton(
              label: 'Get started',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.signUp),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppTextLink(
              label: 'I already have an account',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PennyMark(size: 132),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Money, made\nfriendly.',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Track every rupee in seconds.\nMeet Penny, your spending buddy.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
