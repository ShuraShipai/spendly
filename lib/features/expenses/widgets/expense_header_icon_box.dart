import 'package:flutter/material.dart';

import 'expense_theme.dart';

class ExpenseHeaderIconBox extends StatelessWidget {
  const ExpenseHeaderIconBox({required this.icon, this.onTap, super.key});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconBox = DecoratedBox(
      decoration: BoxDecoration(
        color: ExpenseTheme.surface(context),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: ExpenseTheme.outline(context)),
      ),
      child: SizedBox.square(dimension: 34, child: Icon(icon, size: 18)),
    );

    if (onTap == null) {
      return iconBox;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: iconBox,
    );
  }
}
