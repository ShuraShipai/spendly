import 'package:flutter/material.dart';

import '../../../core/widgets/expense_summary_tile.dart';
import '../models/expense_entry.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    required this.expense,
    this.onTap,
    this.showDate = false,
    super.key,
  });

  final ExpenseEntry expense;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final subtitle = showDate
        ? '${expense.category.label} · ${expense.paymentMethod.label} · ${expense.dateLabel}'
        : '${expense.category.label} · ${expense.paymentMethod.label}';

    return ExpenseSummaryTile(
      onTap: onTap,
      title: expense.displayTitle,
      subtitle: subtitle,
      amountLabel: expense.amountLabel,
      icon: expense.category.icon,
      iconColor: expense.category.color,
    );
  }
}
