import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_filter_chip_data.dart';
import 'expense_theme.dart';

class ExpenseFilterSummary extends StatelessWidget {
  const ExpenseFilterSummary({
    required this.activeFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
    this.showMonthFilter = true,
    this.showAmountFilter = true,
    this.onAmountFilterTap,
    super.key,
  });

  final List<ExpenseFilterChipData> activeFilters;
  final ValueChanged<ExpenseFilterChipData> onRemoveFilter;
  final VoidCallback onClearAll;
  final bool showMonthFilter;
  final bool showAmountFilter;
  final VoidCallback? onAmountFilterTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FILTERS',
          style: textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: ExpenseTheme.muted(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final filter in activeFilters)
              GestureDetector(
                onTap: () => onRemoveFilter(filter),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter.label,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.close_rounded,
                          color: colorScheme.onPrimary,
                          size: 11,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (showMonthFilter) _buildPassiveChip(context, 'This month'),
            if (showAmountFilter)
              _buildPassiveChip(context, '+ Amount', onTap: onAmountFilterTap),
            if (activeFilters.isNotEmpty)
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  foregroundColor: ExpenseTheme.muted(context),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Clear'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPassiveChip(
    BuildContext context,
    String label, {
    VoidCallback? onTap,
  }) {
    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: ExpenseTheme.surface(context),
        border: Border.all(color: ExpenseTheme.outline(context), width: 1.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ExpenseTheme.muted(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return GestureDetector(onTap: onTap, child: chip);
  }
}
