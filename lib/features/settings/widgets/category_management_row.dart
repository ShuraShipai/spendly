import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../expenses/models/expense_category.dart';

class CategoryManagementRow extends StatelessWidget {
  const CategoryManagementRow({
    required this.category,
    required this.onDelete,
    super.key,
  });

  final ExpenseCategory category;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(10),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  category.isCustom ? 'Custom category' : 'Default category',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkSubtle),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              color: AppColors.danger,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
