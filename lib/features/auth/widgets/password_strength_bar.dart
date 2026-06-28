import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({
    required this.label,
    required this.activeSegments,
    this.warning = false,
    super.key,
  });

  final String label;
  final int activeSegments;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final activeColor = warning ? AppColors.warning : AppColors.mint;
    final textColor = warning ? AppColors.warning : AppColors.mintDark;

    return Row(
      children: [
        for (var index = 0; index < 4; index++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: index < activeSegments ? activeColor : AppColors.line,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
          ),
          if (index != 3) const SizedBox(width: AppSpacing.xs),
        ],
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: textColor),
        ),
      ],
    );
  }
}
