import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';

class SavedExpenseCard extends StatelessWidget {
  const SavedExpenseCard({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3C504B),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: expense.category.color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: SizedBox.square(
                dimension: 42,
                child: Icon(expense.category.icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${expense.subtitle} · ${expense.dateLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              expense.amountLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
