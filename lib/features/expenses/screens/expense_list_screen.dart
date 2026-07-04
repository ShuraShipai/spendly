import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';
import '../models/expense_filter_chip_data.dart';
import '../models/expense_sort_option.dart';
import '../models/payment_method.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_amount_range_filter.dart';
import '../widgets/empty_expenses_list.dart';
import '../widgets/expense_day_header.dart';
import '../widgets/expense_filter_sheet.dart';
import '../widgets/expense_filter_summary.dart';
import '../widgets/expense_inline_sort_control.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/expense_list_header.dart';
import '../widgets/expense_search_field.dart';
import '../widgets/expense_sort_sheet.dart';
import '../widgets/mint_action_button.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({this.onSearchModeChanged, super.key});

  final ValueChanged<bool>? onSearchModeChanged;

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
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
      return _buildSearchMode(
        expenses: expenses,
        visibleExpenses: visibleExpenses,
        activeFilters: activeFilters,
        amountBounds: amountBounds,
        amountRange: amountRange,
      );
    }

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
            isSearching: _isSearching,
            hasFilters: hasFilters,
            onSearchPressed: _toggleSearch,
            onFilterPressed: () => _showFilterSheet(expenseProvider),
          ),
          if (_isSearching) ...[
            const SizedBox(height: AppSpacing.sm),
            ExpenseSearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              onCancel: _cancelSearch,
            ),
          ],
          if (activeFilters.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ExpenseFilterSummary(
              activeFilters: activeFilters,
              onRemoveFilter: _removeFilter,
              onClearAll: _clearFilters,
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
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.expenseDetail, arguments: expense.id);
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }

  Widget _buildSearchMode({
    required List<ExpenseEntry> expenses,
    required List<ExpenseEntry> visibleExpenses,
    required List<ExpenseFilterChipData> activeFilters,
    required RangeValues amountBounds,
    required RangeValues amountRange,
  }) {
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
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              onCancel: _cancelSearch,
            ),
            const SizedBox(height: AppSpacing.md),
            ExpenseFilterSummary(
              activeFilters: activeFilters,
              onRemoveFilter: _removeFilter,
              onClearAll: _clearFilters,
              showAmountFilter: !_showAmountFilter,
              onAmountFilterTap: _showAmountRange,
            ),
            if (_showAmountFilter) ...[
              const SizedBox(height: AppSpacing.md),
              ExpenseAmountRangeFilter(
                values: amountRange,
                min: amountBounds.start,
                max: amountBounds.end,
                onChanged: (values) => setState(() => _amountRange = values),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ExpenseInlineSortControl(
              selectedOption: _sortOption,
              onTap: _showSortSheet,
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
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.expenseDetail,
                              arguments: expense.id,
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            MintActionButton(
              label: _resultButtonLabel(visibleExpenses.length),
              onPressed: () => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
      ),
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
    _searchController.clear();
    setState(() {
      _query = '';
      _isSearching = false;
      _showAmountFilter = false;
      _amountRange = null;
    });
    widget.onSearchModeChanged?.call(false);
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
