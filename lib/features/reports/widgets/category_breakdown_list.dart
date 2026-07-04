import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/category_spend_summary.dart';
import 'category_breakdown_row.dart';

class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({
    required this.summaries,
    required this.total,
    super.key,
  });

  final List<CategorySpendSummary> summaries;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty || total == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final summary in summaries.take(5)) ...[
          CategoryBreakdownRow(summary: summary, total: total),
          const SizedBox(height: AppSpacing.sm + 1),
        ],
      ],
    );
  }
}
