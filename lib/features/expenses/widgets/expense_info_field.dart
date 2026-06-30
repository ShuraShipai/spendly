import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'section_label.dart';

class ExpenseInfoField extends StatelessWidget {
  const ExpenseInfoField({
    required this.label,
    required this.value,
    this.icon,
    this.indicatorColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.card,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.mint, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                ],
                if (indicatorColor != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 9),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
