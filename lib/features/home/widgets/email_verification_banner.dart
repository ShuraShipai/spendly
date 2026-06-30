import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

class EmailVerificationBanner extends StatelessWidget {
  const EmailVerificationBanner({
    required this.email,
    required this.isLoading,
    required this.onResend,
    required this.onDismiss,
    super.key,
  });

  final String email;
  final bool isLoading;
  final VoidCallback onResend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final emailCopy = email.isEmpty ? 'your email' : email;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warningSurface, Color(0xFFFFEBC4)],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: const Color(0xFFFFD98A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const SizedBox.square(
                dimension: 40,
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify your email',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF8A6914),
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'We sent a link to $emailCopy. Verify to secure your account.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9A7A2C),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _BannerActionButton(
                        label: isLoading ? 'Sending...' : 'Resend email',
                        onPressed: isLoading ? null : onResend,
                      ),
                      TextButton(
                        onPressed: onDismiss,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9A7A2C),
                          textStyle: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerActionButton extends StatelessWidget {
  const _BannerActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}
