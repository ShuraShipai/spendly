import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

class AmountShortcut extends StatelessWidget {
  const AmountShortcut({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ExpenseTheme.mintContainer(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ExpenseTheme.onMintContainer(context),
            ),
          ),
        ),
      ),
    );
  }
}
