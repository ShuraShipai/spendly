import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'expense_theme.dart';

class DeleteExpenseIcon extends StatelessWidget {
  const DeleteExpenseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExpenseTheme.dangerContainer(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const SizedBox.square(
        dimension: 60,
        child: Icon(
          Icons.delete_outline_rounded,
          color: AppColors.danger,
          size: 28,
        ),
      ),
    );
  }
}
