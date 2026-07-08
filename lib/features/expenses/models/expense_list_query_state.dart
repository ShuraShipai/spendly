import 'package:flutter/material.dart';

import 'expense_category.dart';
import 'expense_entry.dart';
import 'expense_filter_chip_data.dart';
import 'expense_sort_option.dart';
import 'payment_method.dart';

class ExpenseListQueryState {
  var isSearching = false;
  var query = '';
  var sortOption = ExpenseSortOption.newest;
  ExpenseSortOption? _sortOptionBeforeSearch;
  final selectedCategoryIds = <String>{};
  final selectedPaymentMethods = <PaymentMethod>{};
  RangeValues? amountRange;
  var showAmountFilter = false;

  bool get hasFilters =>
      selectedCategoryIds.isNotEmpty || selectedPaymentMethods.isNotEmpty;

  void toggleSearch() {
    isSearching = !isSearching;
    if (isSearching) {
      _sortOptionBeforeSearch ??= sortOption;
      sortOption = ExpenseSortOption.highestAmount;
      return;
    }

    _restoreSortOption();
  }

  void reset() {
    query = '';
    isSearching = false;
    _restoreSortOption();
    selectedCategoryIds.clear();
    selectedPaymentMethods.clear();
    showAmountFilter = false;
    amountRange = null;
  }

  void clearFilters() {
    selectedCategoryIds.clear();
    selectedPaymentMethods.clear();
    amountRange = null;
    showAmountFilter = false;
  }

  void removeFilter(ExpenseFilterChipData filter) {
    switch (filter.type) {
      case ExpenseFilterChipType.category:
        selectedCategoryIds.remove(filter.id);
      case ExpenseFilterChipType.paymentMethod:
        selectedPaymentMethods.removeWhere(
          (method) => method.name == filter.id,
        );
      case ExpenseFilterChipType.amount:
        amountRange = null;
        showAmountFilter = false;
    }
  }

  void applyFilters(
    Set<String> categoryIds,
    Set<PaymentMethod> paymentMethods,
  ) {
    selectedCategoryIds
      ..clear()
      ..addAll(categoryIds);
    selectedPaymentMethods
      ..clear()
      ..addAll(paymentMethods);
  }

  List<ExpenseFilterChipData> activeFilters({
    required Iterable<ExpenseCategory> categories,
    required RangeValues amountBounds,
  }) {
    return [
      for (final category in categories)
        if (selectedCategoryIds.contains(category.id))
          ExpenseFilterChipData(
            id: category.id,
            label: category.label,
            type: ExpenseFilterChipType.category,
          ),
      for (final method in selectedPaymentMethods)
        ExpenseFilterChipData(
          id: method.name,
          label: method.label,
          type: ExpenseFilterChipType.paymentMethod,
        ),
      if (showAmountFilter && isAmountRangeActive(amountBounds))
        ExpenseFilterChipData(
          id: 'amount',
          label:
              '${_formatAmount(amountRange!.start)} - '
              '${_formatAmount(amountRange!.end)}',
          type: ExpenseFilterChipType.amount,
        ),
    ];
  }

  bool isAmountRangeActive(RangeValues amountBounds) {
    final range = amountRange;
    if (range == null) {
      return false;
    }

    return range.start != amountBounds.start || range.end != amountBounds.end;
  }

  RangeValues amountBoundsFor(List<ExpenseEntry> expenses) {
    if (expenses.isEmpty) {
      return const RangeValues(0, 1000);
    }

    final maxExpense = expenses
        .map((expense) => expense.amount)
        .reduce((a, b) => a > b ? a : b);
    final roundedMax = _roundUpToStep(maxExpense, 50);

    return RangeValues(0, roundedMax <= 0 ? 1000 : roundedMax);
  }

  RangeValues clampedAmountRange(RangeValues bounds) {
    final range = amountRange;
    if (range == null) {
      return bounds;
    }

    final start = range.start.clamp(bounds.start, bounds.end).toDouble();
    final end = range.end.clamp(start, bounds.end).toDouble();
    final clampedRange = RangeValues(start, end);

    if (clampedRange != range) {
      amountRange = clampedRange;
    }

    return clampedRange;
  }

  String resultButtonLabel(int count) {
    if (count == 1) {
      return 'Show 1 result';
    }

    return 'Show $count results';
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

  void _restoreSortOption() {
    final previousSort = _sortOptionBeforeSearch;
    if (previousSort != null) {
      sortOption = previousSort;
      _sortOptionBeforeSearch = null;
    }
  }
}
