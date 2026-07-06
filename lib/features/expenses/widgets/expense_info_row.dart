import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

class ExpenseInfoRow extends StatelessWidget {
  const ExpenseInfoRow({
    required this.label,
    required this.value,
    this.color,
    this.isLast = false,
    super.key,
  });

  final String label;
  final String value;
  final Color? color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: ExpenseTheme.outline(context))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ExpenseTheme.subtle(context),
                ),
              ),
            ),
            if (color != null) ...[
              DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox.square(dimension: 9),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
