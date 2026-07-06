import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'expense_theme.dart';

class ExpenseDeleteButton extends StatelessWidget {
  const ExpenseDeleteButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ExpenseTheme.dangerContainer(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox.square(
          dimension: 54,
          child: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
        ),
      ),
    );
  }
}
