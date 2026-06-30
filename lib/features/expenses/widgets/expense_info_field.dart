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
    this.onTap,
    this.hasError = false,
    this.helperText,
    this.showDisclosure = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? indicatorColor;
  final VoidCallback? onTap;
  final bool hasError;
  final String? helperText;
  final bool showDisclosure;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = hasError ? AppColors.danger : AppColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.xs),
        Material(
          color: isDark ? AppColors.darkSurface : AppColors.card,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: borderColor, width: 1.5),
              ),
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
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: value.isEmpty
                            ? AppColors.inkSubtle
                            : Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (onTap != null || showDisclosure)
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.inkSubtle,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            helperText!,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
