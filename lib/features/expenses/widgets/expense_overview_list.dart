import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/expense_day_group.dart';
import '../models/expense_entry.dart';
import '../models/expense_filter_chip_data.dart';
import 'empty_expenses_list.dart';
import 'expense_day_header.dart';
import 'expense_filter_summary.dart';
import 'expense_list_header.dart';
import 'expense_list_tile.dart';
import 'expense_search_field.dart';

class ExpenseOverviewList extends StatelessWidget {
  const ExpenseOverviewList({
    required this.isSearching,
    required this.hasFilters,
    required this.expenses,
    required this.visibleExpenses,
    required this.groupedExpenses,
    required this.activeFilters,
    required this.searchController,
    required this.onSearchPressed,
    required this.onFilterPressed,
    required this.onQueryChanged,
    required this.onCancelSearch,
    required this.onRemoveFilter,
    required this.onClearFilters,
    required this.onExpenseTap,
    super.key,
  });

  final bool isSearching;
  final bool hasFilters;
  final List<ExpenseEntry> expenses;
  final List<ExpenseEntry> visibleExpenses;
  final List<ExpenseDayGroup> groupedExpenses;
  final List<ExpenseFilterChipData> activeFilters;
  final TextEditingController searchController;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onCancelSearch;
  final ValueChanged<ExpenseFilterChipData> onRemoveFilter;
  final VoidCallback onClearFilters;
  final ValueChanged<ExpenseEntry> onExpenseTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          ExpenseListHeader(
            isSearching: isSearching,
            hasFilters: hasFilters,
            onSearchPressed: onSearchPressed,
            onFilterPressed: onFilterPressed,
          ),
          if (isSearching) ...[
            const SizedBox(height: AppSpacing.sm),
            ExpenseSearchField(
              controller: searchController,
              onChanged: onQueryChanged,
              onCancel: onCancelSearch,
            ),
          ],
          if (activeFilters.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ExpenseFilterSummary(
              activeFilters: activeFilters,
              onRemoveFilter: onRemoveFilter,
              onClearAll: onClearFilters,
              showMonthFilter: false,
              showAmountFilter: false,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (expenses.isEmpty)
            const EmptyExpensesList()
          else if (visibleExpenses.isEmpty)
            const EmptyExpensesList(
              title: 'No matching expenses',
              message: 'Try changing your search or filters.',
            )
          else
            for (final group in groupedExpenses) ...[
              ExpenseDayHeader(date: group.date, total: group.total),
              const SizedBox(height: AppSpacing.xs),
              for (final expense in group.expenses) ...[
                ExpenseListTile(
                  expense: expense,
                  onTap: () => onExpenseTap(expense),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}
