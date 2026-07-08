import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';
import '../models/expense_filter_chip_data.dart';
import '../models/expense_sort_option.dart';
import 'empty_expenses_list.dart';
import 'expense_amount_range_filter.dart';
import 'expense_filter_summary.dart';
import 'expense_inline_sort_control.dart';
import 'expense_list_tile.dart';
import 'expense_search_field.dart';
import 'mint_action_button.dart';

class ExpenseSearchResultsView extends StatelessWidget {
  const ExpenseSearchResultsView({
    required this.searchController,
    required this.expenses,
    required this.visibleExpenses,
    required this.activeFilters,
    required this.amountBounds,
    required this.amountRange,
    required this.showAmountFilter,
    required this.sortOption,
    required this.resultButtonLabel,
    required this.onQueryChanged,
    required this.onCancelSearch,
    required this.onRemoveFilter,
    required this.onClearFilters,
    required this.onAmountFilterTap,
    required this.onAmountRangeChanged,
    required this.onSortTap,
    required this.onExpenseTap,
    super.key,
  });

  final TextEditingController searchController;
  final List<ExpenseEntry> expenses;
  final List<ExpenseEntry> visibleExpenses;
  final List<ExpenseFilterChipData> activeFilters;
  final RangeValues amountBounds;
  final RangeValues amountRange;
  final bool showAmountFilter;
  final ExpenseSortOption sortOption;
  final String resultButtonLabel;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onCancelSearch;
  final ValueChanged<ExpenseFilterChipData> onRemoveFilter;
  final VoidCallback onClearFilters;
  final VoidCallback onAmountFilterTap;
  final ValueChanged<RangeValues> onAmountRangeChanged;
  final VoidCallback onSortTap;
  final ValueChanged<ExpenseEntry> onExpenseTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          children: [
            ExpenseSearchField(
              controller: searchController,
              onChanged: onQueryChanged,
              onCancel: onCancelSearch,
            ),
            const SizedBox(height: AppSpacing.md),
            ExpenseFilterSummary(
              activeFilters: activeFilters,
              onRemoveFilter: onRemoveFilter,
              onClearAll: onClearFilters,
              showAmountFilter: !showAmountFilter,
              onAmountFilterTap: onAmountFilterTap,
            ),
            if (showAmountFilter) ...[
              const SizedBox(height: AppSpacing.md),
              ExpenseAmountRangeFilter(
                values: amountRange,
                min: amountBounds.start,
                max: amountBounds.end,
                onChanged: onAmountRangeChanged,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ExpenseInlineSortControl(
              selectedOption: sortOption,
              onTap: onSortTap,
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Expanded(
              child: expenses.isEmpty
                  ? const EmptyExpensesList()
                  : visibleExpenses.isEmpty
                  ? const EmptyExpensesList(
                      title: 'No matching expenses',
                      message: 'Try a different search or clear your filters.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: visibleExpenses.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final expense = visibleExpenses[index];
                        return ExpenseListTile(
                          expense: expense,
                          showDate: true,
                          onTap: () => onExpenseTap(expense),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            MintActionButton(
              label: resultButtonLabel,
              onPressed: () => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
      ),
    );
  }
}
