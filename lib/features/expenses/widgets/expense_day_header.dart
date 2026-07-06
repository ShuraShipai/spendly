import 'package:flutter/material.dart';

import 'expense_theme.dart';

class ExpenseDayHeader extends StatelessWidget {
  const ExpenseDayHeader({required this.date, required this.total, super.key});

  final DateTime date;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _formatDate(date),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ExpenseTheme.muted(context),
            ),
          ),
        ),
        Text(
          _formatAmount(total),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: ExpenseTheme.subtle(context),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final yesterdayOnly = todayOnly.subtract(const Duration(days: 1));

    if (date == todayOnly) {
      return 'Today, ${date.day} ${_monthName(date)}';
    }
    if (date == yesterdayOnly) {
      return 'Yesterday, ${date.day} ${_monthName(date)}';
    }
    return '${date.day} ${_monthName(date)} ${date.year}';
  }

  String _monthName(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[date.month - 1];
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}
