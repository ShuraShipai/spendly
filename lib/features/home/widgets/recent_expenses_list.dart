import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../expenses/models/expense_entry.dart';

class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({required this.expenses, super.key});

  final List<ExpenseEntry> expenses;

  @override
  Widget build(BuildContext context) {
    final visibleExpenses = expenses.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent expenses', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final expense in visibleExpenses) ...[
          _RecentExpenseTile(expense: expense),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _RecentExpenseTile extends StatelessWidget {
  const _RecentExpenseTile({required this.expense});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkInkMuted : AppColors.line,
        ),
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
                color: expense.category.color,
                borderRadius: BorderRadius.circular(11),
              ),
              child: SizedBox.square(
                dimension: 34,
                child: Icon(
                  expense.category.icon,
                  color: Colors.white,
                  size: 17,
                ),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${expense.subtitle} · ${expense.paymentMethod.label} · ${expense.dateLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              expense.amountLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
