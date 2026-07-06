import 'package:flutter/material.dart';

import 'expense_theme.dart';

class ExpenseSheetIconButton extends StatelessWidget {
  const ExpenseSheetIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ExpenseTheme.surface(context),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox.square(
          dimension: 34,
          child: Icon(
            icon,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
    );
  }
}
