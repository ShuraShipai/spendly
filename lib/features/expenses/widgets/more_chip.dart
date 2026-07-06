import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

class MoreChip extends StatelessWidget {
  const MoreChip({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ExpenseTheme.surface(context),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: ExpenseTheme.outline(context),
              width: 1.5,
            ),
          ),
          child: Text(
            '+ More',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ExpenseTheme.subtle(context),
            ),
          ),
        ),
      ),
    );
  }
}
