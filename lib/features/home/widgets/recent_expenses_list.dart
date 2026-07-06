import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/expense_summary_tile.dart';
import '../../expenses/models/expense_entry.dart';

class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({
    required this.expenses,
    this.onExpenseTap,
    super.key,
  });

  final List<ExpenseEntry> expenses;
  final ValueChanged<ExpenseEntry>? onExpenseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent expenses', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final expense in expenses) ...[
          ExpenseSummaryTile(
            title: expense.displayTitle,
            subtitle:
                '${expense.category.label} · ${expense.paymentMethod.label}',
            amountLabel: expense.amountLabel,
            icon: expense.category.icon,
            iconColor: expense.category.color,
            onTap: onExpenseTap == null ? null : () => onExpenseTap!(expense),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
