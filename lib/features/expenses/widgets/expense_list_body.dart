import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../models/expense_entry.dart';
import '../models/expense_list_query_state.dart';
import '../providers/expense_provider.dart';
import 'expense_list_sheet_launcher.dart';
import 'expense_overview_list.dart';
import 'expense_search_results_view.dart';

class ExpenseListBody extends StatefulWidget {
  const ExpenseListBody({
    this.temporaryStateResetToken = 0,
    this.onSearchModeChanged,
    super.key,
  });

  final int temporaryStateResetToken;
  final ValueChanged<bool>? onSearchModeChanged;

  @override
  State<ExpenseListBody> createState() => _ExpenseListBodyState();
}

class _ExpenseListBodyState extends State<ExpenseListBody> {
  final _searchController = TextEditingController();
  final _queryState = ExpenseListQueryState();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExpenseListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.temporaryStateResetToken != widget.temporaryStateResetToken) {
      _resetTemporaryState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    final amountBounds = _queryState.amountBoundsFor(expenses);
    final amountRange = _queryState.clampedAmountRange(amountBounds);
    final visibleExpenses = expenseProvider.visibleExpenses(
      query: _queryState.query,
      sortOption: _queryState.sortOption,
      selectedCategoryIds: _queryState.selectedCategoryIds,
      selectedPaymentMethods: _queryState.selectedPaymentMethods,
      minAmount: _queryState.isSearching && _queryState.showAmountFilter
          ? amountRange.start
          : null,
      maxAmount: _queryState.isSearching && _queryState.showAmountFilter
          ? amountRange.end
          : null,
    );
    final groupedExpenses = expenseProvider.groupByDay(visibleExpenses);
    final activeFilters = _queryState.activeFilters(
      categories: expenseProvider.availableCategories(),
      amountBounds: amountBounds,
    );

    if (_queryState.isSearching) {
      return ExpenseSearchResultsView(
        searchController: _searchController,
        expenses: expenses,
        visibleExpenses: visibleExpenses,
        activeFilters: activeFilters,
        amountBounds: amountBounds,
        amountRange: amountRange,
        showAmountFilter: _queryState.showAmountFilter,
        sortOption: _queryState.sortOption,
        resultButtonLabel: _queryState.resultButtonLabel(
          visibleExpenses.length,
        ),
        onQueryChanged: (value) => setState(() => _queryState.query = value),
        onCancelSearch: _cancelSearch,
        onRemoveFilter: (filter) {
          setState(() => _queryState.removeFilter(filter));
        },
        onClearFilters: () {
          setState(_queryState.clearFilters);
        },
        onAmountFilterTap: _showAmountRange,
        onAmountRangeChanged: (values) {
          setState(() => _queryState.amountRange = values);
        },
        onSortTap: () => _showSortSheet(),
        onExpenseTap: _openExpenseDetail,
      );
    }

    return ExpenseOverviewList(
      isSearching: _queryState.isSearching,
      hasFilters: _queryState.hasFilters,
      expenses: expenses,
      visibleExpenses: visibleExpenses,
      groupedExpenses: groupedExpenses,
      activeFilters: activeFilters,
      searchController: _searchController,
      onSearchPressed: _toggleSearch,
      onFilterPressed: () => _showFilterSheet(expenseProvider),
      onQueryChanged: (value) => setState(() => _queryState.query = value),
      onCancelSearch: _cancelSearch,
      onRemoveFilter: (filter) {
        setState(() => _queryState.removeFilter(filter));
      },
      onClearFilters: () {
        setState(_queryState.clearFilters);
      },
      onExpenseTap: _openExpenseDetail,
    );
  }

  void _toggleSearch() {
    setState(_queryState.toggleSearch);
    widget.onSearchModeChanged?.call(_queryState.isSearching);
  }

  void _cancelSearch() {
    _resetTemporaryState();
    widget.onSearchModeChanged?.call(false);
  }

  void _resetTemporaryState() {
    _searchController.clear();
    setState(_queryState.reset);
  }

  void _showAmountRange() {
    setState(() => _queryState.showAmountFilter = true);
  }

  void _showSortSheet() {
    ExpenseListSheetLauncher.showSortSheet(
      context: context,
      selectedOption: _queryState.sortOption,
      onSelected: (option) {
        setState(() => _queryState.sortOption = option);
      },
    );
  }

  void _showFilterSheet(ExpenseProvider expenseProvider) {
    ExpenseListSheetLauncher.showFilterSheet(
      context: context,
      categories: expenseProvider.availableCategories(),
      selectedCategoryIds: _queryState.selectedCategoryIds,
      selectedPaymentMethods: _queryState.selectedPaymentMethods,
      onApply: (categoryIds, paymentMethods) {
        setState(() => _queryState.applyFilters(categoryIds, paymentMethods));
      },
    );
  }

  void _openExpenseDetail(ExpenseEntry expense) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.expenseDetail, arguments: expense.id);
  }
}
