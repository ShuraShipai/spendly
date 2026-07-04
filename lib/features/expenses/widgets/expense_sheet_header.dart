import 'package:flutter/material.dart';

import 'expense_sheet_icon_button.dart';

class ExpenseSheetHeader extends StatelessWidget {
  const ExpenseSheetHeader({
    required this.title,
    required this.leadingIcon,
    required this.onLeadingPressed,
    super.key,
  });

  final String title;
  final IconData leadingIcon;
  final VoidCallback onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExpenseSheetIconButton(icon: leadingIcon, onPressed: onLeadingPressed),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox.square(dimension: 34),
      ],
    );
  }
}
