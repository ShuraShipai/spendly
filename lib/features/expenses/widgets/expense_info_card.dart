import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';

class ExpenseInfoCard extends StatelessWidget {
  const ExpenseInfoCard({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkInkMuted : AppColors.line,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Category',
            value: expense.category.label,
            color: expense.category.color,
          ),
          _InfoRow(label: 'Date', value: expense.dateLabel),
          _InfoRow(label: 'Payment', value: expense.paymentMethod.label),
          _InfoRow(
            label: 'Note',
            value: expense.note?.trim().isEmpty ?? true
                ? '-'
                : expense.note!.trim(),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.color,
    this.isLast = false,
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
            : const Border(bottom: BorderSide(color: AppColors.line)),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkSubtle),
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
