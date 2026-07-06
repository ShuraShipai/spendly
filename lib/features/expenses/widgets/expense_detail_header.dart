import 'package:flutter/material.dart';

import 'expense_header_icon_box.dart';

class ExpenseDetailHeader extends StatelessWidget {
  const ExpenseDetailHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExpenseHeaderIconBox(icon: Icons.chevron_left_rounded, onTap: onBack),
        Expanded(
          child: Text(
            'Expense',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox.square(dimension: 34),
      ],
    );
  }
}
