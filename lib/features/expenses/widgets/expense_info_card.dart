import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_entry.dart';
import 'expense_info_row.dart';

class ExpenseInfoCard extends StatelessWidget {
  const ExpenseInfoCard({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkInkMuted : AppColors.line,
        ),
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
