import 'package:flutter/foundation.dart';

import '../models/expense_category.dart';
import '../models/expense_day_group.dart';
import '../models/expense_entry.dart';
import '../models/expense_sort_option.dart';
import '../models/payment_method.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseEntry> _expenses = [];

  List<ExpenseEntry> get expenses => List.unmodifiable(_expenses);

  double get totalSpent {
    return _expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  ExpenseEntry? expenseById(String id) {
    for (final expense in _expenses) {
      if (expense.id == id) {
        return expense;
      }
    }

    return null;
  }

  List<ExpenseEntry> expensesForDay(DateTime day) {
    return _expenses
        .where(
          (expense) =>
              expense.date.year == day.year &&
              expense.date.month == day.month &&
              expense.date.day == day.day,
        )
        .toList(growable: false);
  }

  List<ExpenseEntry> expensesForWeek(DateTime week) {
    final startOfWeek = _startOfWeek(week);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _expenses
        .where(
          (expense) =>
              !expense.date.isBefore(startOfWeek) &&
              expense.date.isBefore(endOfWeek),
        )
        .toList(growable: false);
  }

  List<ExpenseEntry> expensesForMonth(DateTime month) {
    return _expenses
        .where(
          (expense) =>
              expense.date.year == month.year &&
              expense.date.month == month.month,
        )
        .toList(growable: false);
  }

  List<ExpenseEntry> visibleExpenses({
    required String query,
    required ExpenseSortOption sortOption,
    Set<String> selectedCategoryIds = const {},
    Set<PaymentMethod> selectedPaymentMethods = const {},
    double? minAmount,
    double? maxAmount,
    DateTime? month,
  }) {
    return sortExpenses(
      filterExpenses(
        query: query,
        selectedCategoryIds: selectedCategoryIds,
        selectedPaymentMethods: selectedPaymentMethods,
        minAmount: minAmount,
        maxAmount: maxAmount,
        month: month,
      ),
      sortOption,
    );
  }

  List<ExpenseEntry> filterExpenses({
    required String query,
    Set<String> selectedCategoryIds = const {},
    Set<PaymentMethod> selectedPaymentMethods = const {},
    double? minAmount,
    double? maxAmount,
    DateTime? month,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return _expenses
        .where((expense) {
          final matchesSearch =
              normalizedQuery.isEmpty ||
              expense.displayTitle.toLowerCase().contains(normalizedQuery) ||
              expense.category.label.toLowerCase().contains(normalizedQuery) ||
              (expense.note?.toLowerCase().contains(normalizedQuery) ??
                  false) ||
              expense.amountLabel.toLowerCase().contains(normalizedQuery);
          final matchesCategory =
              selectedCategoryIds.isEmpty ||
              selectedCategoryIds.contains(expense.category.id);
          final matchesPayment =
              selectedPaymentMethods.isEmpty ||
              selectedPaymentMethods.contains(expense.paymentMethod);
          final matchesMin = minAmount == null || expense.amount >= minAmount;
          final matchesMax = maxAmount == null || expense.amount <= maxAmount;
          final matchesMonth =
              month == null ||
              (expense.date.year == month.year &&
                  expense.date.month == month.month);

          return matchesSearch &&
              matchesCategory &&
              matchesPayment &&
              matchesMin &&
              matchesMax &&
              matchesMonth;
        })
        .toList(growable: false);
  }

  List<ExpenseEntry> sortExpenses(
    List<ExpenseEntry> expenses,
    ExpenseSortOption sortOption,
  ) {
    final sorted = [...expenses];
    sorted.sort((a, b) {
      return switch (sortOption) {
        ExpenseSortOption.newest => b.date.compareTo(a.date),
        ExpenseSortOption.oldest => a.date.compareTo(b.date),
        ExpenseSortOption.highestAmount => b.amount.compareTo(a.amount),
        ExpenseSortOption.lowestAmount => a.amount.compareTo(b.amount),
      };
    });
    return sorted;
  }

  List<ExpenseCategory> availableCategories([List<ExpenseEntry>? source]) {
    final categories = [...ExpenseCategory.defaults];
    for (final expense in source ?? _expenses) {
      if (!categories.contains(expense.category)) {
        categories.add(expense.category);
      }
    }
    return categories;
  }

  List<String> filterLabels({
    required Set<String> selectedCategoryIds,
    required Set<PaymentMethod> selectedPaymentMethods,
  }) {
    final labels = <String>[];
    for (final category in availableCategories()) {
      if (selectedCategoryIds.contains(category.id)) {
        labels.add(category.label);
      }
    }
    labels.addAll(selectedPaymentMethods.map((method) => method.label));
    return labels;
  }

  List<ExpenseDayGroup> groupByDay(List<ExpenseEntry> expenses) {
    final groups = <DateTime, List<ExpenseEntry>>{};
    for (final expense in expenses) {
      final day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      groups.putIfAbsent(day, () => []).add(expense);
    }

    final sortedDays = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in sortedDays)
        ExpenseDayGroup(date: day, expenses: groups[day]!),
    ];
  }

  double totalSpentForDay(DateTime day) {
    return _totalFor(expensesForDay(day));
  }

  double totalSpentForWeek(DateTime week) {
    return _totalFor(expensesForWeek(week));
  }

  double totalSpentForMonth(DateTime month) {
    return _totalFor(expensesForMonth(month));
  }

  void addExpense(ExpenseEntry expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  void updateExpense(ExpenseEntry expense) {
    final index = _expenses.indexWhere((entry) => entry.id == expense.id);
    if (index < 0) {
      return;
    }

    _expenses[index] = expense;
    notifyListeners();
  }

  ExpenseEntry? deleteExpense(String id) {
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index < 0) {
      return null;
    }

    final expense = _expenses.removeAt(index);
    notifyListeners();
    return expense;
  }

  void restoreExpense(ExpenseEntry expense) {
    if (_expenses.any((entry) => entry.id == expense.id)) {
      return;
    }

    _expenses.insert(0, expense);
    notifyListeners();
  }

  double _totalFor(List<ExpenseEntry> expenses) {
    return expenses.fold<double>(0, (total, expense) => total + expense.amount);
  }

  DateTime _startOfWeek(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }
}
