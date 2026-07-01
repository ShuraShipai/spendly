import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';

class CategoryListRow extends StatelessWidget {
  const CategoryListRow({
    required this.category,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? AppColors.mint
        : isDark
        ? AppColors.darkInkMuted
        : AppColors.line;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: SizedBox.square(
                  dimension: 34,
                  child: Icon(category.icon, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      category.isCustom
                          ? 'Custom category'
                          : 'Default category',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? AppColors.mint : AppColors.inkSubtle,
                size: selected ? 21 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
