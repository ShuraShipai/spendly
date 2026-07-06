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
    final warning = budget > 0 && progress >= 0.8 && progress < 1;
    final exceeded = budget > 0 && spent > budget;
    final progressColor = exceeded
        ? AppColors.danger
        : warning
        ? AppColors.warning
        : category.color;
    final amountColor = exceeded
        ? AppColors.danger
        : warning
        ? AppColors.warning
        : AppColors.inkSubtle;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const SizedBox.square(dimension: 10),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      category.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    budget == 0
                        ? 'No limit'
                        : '${_formatAmount(spent)} / ${_formatAmount(budget)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: amountColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.line,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (warning || exceeded) ...[
                const SizedBox(height: 5),
                Text(
                  exceeded
                      ? '${_formatAmount(spent - budget)} over limit'
                      : '⚠ Approaching limit · ${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: progressColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
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
