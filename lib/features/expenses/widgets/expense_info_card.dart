import 'package:flutter/material.dart';

import '../models/expense_entry.dart';
import 'expense_info_row.dart';
import 'expense_theme.dart';

class ExpenseInfoCard extends StatelessWidget {
  const ExpenseInfoCard({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExpenseTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ExpenseTheme.outline(context)),
      ),
      child: Column(
        children: [
          ExpenseInfoRow(
            label: 'Category',
            value: expense.category.label,
            color: expense.category.color,
          ),
          ExpenseInfoRow(label: 'Date', value: expense.dateLabel),
          ExpenseInfoRow(label: 'Payment', value: expense.paymentMethod.label),
          ExpenseInfoRow(
            label: 'Note',
            value: expense.note?.trim().isEmpty ?? true
                ? '-'
                : expense.note!.trim(),
            isLast: true,
          ),
        ],
      ),
    );
  }
}
