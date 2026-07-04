import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'expense_header_icon_button.dart';

class ExpenseListHeader extends StatelessWidget {
  const ExpenseListHeader({
    required this.isSearching,
    required this.hasFilters,
    required this.onSearchPressed,
    required this.onFilterPressed,
    super.key,
  });

  final bool isSearching;
  final bool hasFilters;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Expenses',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ExpenseHeaderIconButton(
          icon: Icons.search_rounded,
          isActive: isSearching,
          onTap: onSearchPressed,
        ),
        const SizedBox(width: AppSpacing.xs),
        ExpenseHeaderIconButton(
          icon: Icons.tune_rounded,
          isActive: hasFilters,
          onTap: onFilterPressed,
        ),
      ],
    );
  }
}
