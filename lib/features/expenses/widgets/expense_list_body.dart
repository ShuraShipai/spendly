import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../models/expense_entry.dart';
import '../models/expense_filter_chip_data.dart';
import '../models/expense_sort_option.dart';
import '../models/payment_method.dart';
import '../providers/expense_provider.dart';
import 'expense_filter_sheet.dart';
import 'expense_overview_list.dart';
import 'expense_search_results_view.dart';
import 'expense_sort_sheet.dart';

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
  var _isSearching = false;
  var _query = '';
  var _sortOption = ExpenseSortOption.newest;
  final _selectedCategoryIds = <String>{};
  final _selectedPaymentMethods = <PaymentMethod>{};
  RangeValues? _amountRange;
  var _showAmountFilter = false;

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
    final amountBounds = _amountBoundsFor(expenses);
    final amountRange = _clampedAmountRange(amountBounds);
    final visibleExpenses = expenseProvider.visibleExpenses(
      query: _query,
      sortOption: _sortOption,
      selectedCategoryIds: _selectedCategoryIds,
      selectedPaymentMethods: _selectedPaymentMethods,
      minAmount: _isSearching && _showAmountFilter ? amountRange.start : null,
      maxAmount: _isSearching && _showAmountFilter ? amountRange.end : null,
    );
    final groupedExpenses = expenseProvider.groupByDay(visibleExpenses);
    final hasFilters =
        _selectedCategoryIds.isNotEmpty || _selectedPaymentMethods.isNotEmpty;
    final activeFilters = _activeFilters(expenseProvider, amountBounds);

    if (_isSearching) {
      return ExpenseSearchResultsView(
        searchController: _searchController,
        expenses: expenses,
        visibleExpenses: visibleExpenses,
        activeFilters: activeFilters,
        amountBounds: amountBounds,
        amountRange: amountRange,
        showAmountFilter: _showAmountFilter,
        sortOption: _sortOption,
        resultButtonLabel: _resultButtonLabel(visibleExpenses.length),
        onQueryChanged: (value) => setState(() => _query = value),
        onCancelSearch: _cancelSearch,
        onRemoveFilter: _removeFilter,
        onClearFilters: _clearFilters,
        onAmountFilterTap: _showAmountRange,
        onAmountRangeChanged: (values) => setState(() => _amountRange = values),
        onSortTap: _showSortSheet,
        onExpenseTap: _openExpenseDetail,
      );
    }

    return ExpenseOverviewList(
      isSearching: _isSearching,
      hasFilters: hasFilters,
      expenses: expenses,
      visibleExpenses: visibleExpenses,
      groupedExpenses: groupedExpenses,
      activeFilters: activeFilters,
      searchController: _searchController,
      onSearchPressed: _toggleSearch,
      onFilterPressed: () => _showFilterSheet(expenseProvider),
      onQueryChanged: (value) => setState(() => _query = value),
      onCancelSearch: _cancelSearch,
      onRemoveFilter: _removeFilter,
      onClearFilters: _clearFilters,
      onExpenseTap: _openExpenseDetail,
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _sortOption = ExpenseSortOption.highestAmount;
      }
    });
    widget.onSearchModeChanged?.call(_isSearching);
  }

  void _cancelSearch() {
    _resetTemporaryState();
    widget.onSearchModeChanged?.call(false);
  }

  void _resetTemporaryState() {
    _searchController.clear();
    setState(() {
      _query = '';
      _isSearching = false;
      _selectedCategoryIds.clear();
      _selectedPaymentMethods.clear();
      _showAmountFilter = false;
      _amountRange = null;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedPaymentMethods.clear();
      _amountRange = null;
      _showAmountFilter = false;
    });
  }

  void _removeFilter(ExpenseFilterChipData filter) {
    setState(() {
      switch (filter.type) {
        case ExpenseFilterChipType.category:
          _selectedCategoryIds.remove(filter.id);
        case ExpenseFilterChipType.paymentMethod:
          _selectedPaymentMethods.removeWhere(
            (method) => method.name == filter.id,
          );
        case ExpenseFilterChipType.amount:
          _amountRange = null;
          _showAmountFilter = false;
      }
    });
  }

  List<ExpenseFilterChipData> _activeFilters(
    ExpenseProvider provider,
    RangeValues amountBounds,
  ) {
    return [
      for (final category in provider.availableCategories())
        if (_selectedCategoryIds.contains(category.id))
          ExpenseFilterChipData(
            id: category.id,
            label: category.label,
            type: ExpenseFilterChipType.category,
          ),
      for (final method in _selectedPaymentMethods)
        ExpenseFilterChipData(
          id: method.name,
          label: method.label,
          type: ExpenseFilterChipType.paymentMethod,
        ),
      if (_showAmountFilter && _isAmountRangeActive(amountBounds))
        ExpenseFilterChipData(
          id: 'amount',
          label:
              '${_formatAmount(_amountRange!.start)} - '
              '${_formatAmount(_amountRange!.end)}',
          type: ExpenseFilterChipType.amount,
        ),
    ];
  }

  void _showAmountRange() {
    setState(() => _showAmountFilter = true);
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ExpenseSortSheet(
          selectedOption: _sortOption,
          onSelected: (option) {
            Navigator.of(context).pop();
            setState(() => _sortOption = option);
          },
        );
      },
    );
  }

  void _showFilterSheet(ExpenseProvider expenseProvider) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ExpenseFilterSheet(
          categories: expenseProvider.availableCategories(),
          selectedCategoryIds: _selectedCategoryIds,
          selectedPaymentMethods: _selectedPaymentMethods,
          onApply: (categoryIds, paymentMethods) {
            Navigator.of(context).pop();
            setState(() {
              _selectedCategoryIds
                ..clear()
                ..addAll(categoryIds);
              _selectedPaymentMethods
                ..clear()
                ..addAll(paymentMethods);
            });
          },
        );
      },
    );
  }

  void _openExpenseDetail(ExpenseEntry expense) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.expenseDetail, arguments: expense.id);
  }

  String _resultButtonLabel(int count) {
    if (count == 1) {
      return 'Show 1 result';
    }

    return 'Show $count results';
  }

  bool _isAmountRangeActive(RangeValues amountBounds) {
    final amountRange = _amountRange;
    if (amountRange == null) {
      return false;
    }

    return amountRange.start != amountBounds.start ||
        amountRange.end != amountBounds.end;
  }

  RangeValues _amountBoundsFor(List<ExpenseEntry> expenses) {
    if (expenses.isEmpty) {
      return const RangeValues(0, 1000);
    }

    final maxExpense = expenses
        .map((expense) => expense.amount)
        .reduce((a, b) => a > b ? a : b);
    final roundedMax = _roundUpToStep(maxExpense, 50);

    return RangeValues(0, roundedMax <= 0 ? 1000 : roundedMax);
  }

  RangeValues _clampedAmountRange(RangeValues bounds) {
    final range = _amountRange;
    if (range == null) {
      return bounds;
    }

    final start = range.start.clamp(bounds.start, bounds.end).toDouble();
    final end = range.end.clamp(start, bounds.end).toDouble();
    final clampedRange = RangeValues(start, end);

    if (clampedRange != range) {
      _amountRange = clampedRange;
    }

    return clampedRange;
  }

  double _roundUpToStep(double value, double step) {
    return ((value / step).ceil() * step).toDouble();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}
