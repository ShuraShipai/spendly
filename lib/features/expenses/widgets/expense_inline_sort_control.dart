import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_sort_option.dart';

class ExpenseInlineSortControl extends StatelessWidget {
  const ExpenseInlineSortControl({
    required this.selectedOption,
    required this.onTap,
    super.key,
  });

  final ExpenseSortOption selectedOption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SORT',
          style: textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.inkMuted,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              children: [
                Text(
                  _labelFor(selectedOption),
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mintDark,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.mintDark,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _labelFor(ExpenseSortOption option) {
    return switch (option) {
      ExpenseSortOption.newest => 'Newest first',
      ExpenseSortOption.oldest => 'Oldest first',
      ExpenseSortOption.highestAmount => 'Amount: high → low',
      ExpenseSortOption.lowestAmount => 'Amount: low → high',
    };
  }
}
