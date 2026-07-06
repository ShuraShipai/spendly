import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({
    required this.onKeyPressed,
    required this.onBackspace,
    super.key,
  });

  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0'];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: AppSpacing.xs,
      childAspectRatio: 1.8,
      children: [
        for (final keyValue in keys)
          TextButton(
            onPressed: () => onKeyPressed(keyValue),
            child: Text(
              keyValue,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        IconButton(
          onPressed: onBackspace,
          icon: Icon(
            Icons.backspace_outlined,
            color: ExpenseTheme.muted(context),
          ),
        ),
      ],
    );
  }
}
