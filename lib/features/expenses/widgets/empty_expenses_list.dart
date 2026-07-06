import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

class EmptyExpensesList extends StatelessWidget {
  const EmptyExpensesList({
    this.title = 'No expenses yet',
    this.message = 'Tap + to add your first expense.',
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: ExpenseTheme.subtle(context),
            size: 54,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
