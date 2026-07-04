import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/category_spend_summary.dart';

class CategoryBreakdownRow extends StatelessWidget {
  const CategoryBreakdownRow({
    required this.summary,
    required this.total,
    super.key,
  });

  final CategorySpendSummary summary;
  final double total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : summary.total / total;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                summary.category.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatAmount(summary.total),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: percent.clamp(0, 1),
            backgroundColor: AppColors.line,
            color: summary.category.color,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}
