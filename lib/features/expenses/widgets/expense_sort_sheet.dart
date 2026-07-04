import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_sort_option.dart';

class ExpenseSortSheet extends StatelessWidget {
  const ExpenseSortSheet({
    required this.selectedOption,
    required this.onSelected,
    super.key,
  });

  final ExpenseSortOption selectedOption;
  final ValueChanged<ExpenseSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final option in ExpenseSortOption.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option.label),
                trailing: option == selectedOption
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.mint,
                      )
                    : null,
                onTap: () => onSelected(option),
              ),
          ],
        ),
      ),
    );
  }
}
