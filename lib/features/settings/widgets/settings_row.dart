import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.iconBackground = AppColors.mintTint,
    this.iconColor = AppColors.mintDark,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final valueWidget = trailing;
    final textStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: SizedBox.square(
              dimension: 30,
              child: Icon(icon, color: iconColor, size: 17),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (valueWidget != null)
            valueWidget
          else if (value != null)
            Text('$value ›', style: textStyle),
        ],
      ),
    );
  }
}
