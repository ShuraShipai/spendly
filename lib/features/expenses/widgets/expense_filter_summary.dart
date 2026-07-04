import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_filter_chip_data.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FILTERS',
          style: textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.inkMuted,
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
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
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
                  foregroundColor: AppColors.inkMuted,
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
        color: AppColors.card,
        border: Border.all(color: AppColors.line, width: 1.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.inkMuted,
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
