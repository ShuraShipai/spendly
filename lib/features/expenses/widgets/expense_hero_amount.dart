import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';

class ExpenseHeroAmount extends StatelessWidget {
  const ExpenseHeroAmount({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: expense.category.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: expense.category.color.withValues(alpha: 0.42),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: 72,
            child: Icon(expense.category.icon, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          expense.amountLabel,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          expense.displayTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.inkMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
