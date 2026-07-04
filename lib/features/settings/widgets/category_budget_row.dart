import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../expenses/models/expense_category.dart';

class CategoryBudgetRow extends StatelessWidget {
  const CategoryBudgetRow({
    required this.category,
    required this.budget,
    required this.spent,
    required this.onTap,
    super.key,
  });

  final ExpenseCategory category;
  final double budget;
  final double spent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        budget == 0 ? 'No limit' : _formatAmount(budget),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      color: progress >= 0.9
                          ? AppColors.danger
                          : category.color,
                      backgroundColor: AppColors.line.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}
