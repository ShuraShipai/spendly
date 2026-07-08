import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/expense_category.dart';
import '../models/expense_day_group.dart';
import '../models/expense_entry.dart';
import '../models/expense_sort_option.dart';
import '../models/payment_method.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({ExpenseService? expenseService})
    : _expenseService = expenseService ?? ExpenseService.memory();

  final ExpenseService _expenseService;
  final List<ExpenseEntry> _expenses = [];
  final Map<String, Future<void>> _pendingDeleteWrites = {};
  StreamSubscription<List<ExpenseEntry>>? _expenseSubscription;
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseEntry> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalSpent {
    return _expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  void bindUser(String? uid) {
    if (_userId == uid) {
      return;
    }

    _userId = uid;
    _expenseSubscription?.cancel();
    _expenseSubscription = null;
    _expenses.clear();
    _errorMessage = null;

    if (uid == null) {
      _setLoading(false);
      notifyListeners();
      return;
    }

    _setLoading(true);
    _expenseSubscription = _expenseService
        .watchActiveExpenses(uid)
        .listen(
          (expenses) {
            _expenses
              ..clear()
              ..addAll(expenses);
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage = 'Could not load expenses.';
            notifyListeners();
          },
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
    final startOfDay = _startOfLocalDay(day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _expenses
        .where((expense) => _isWithinLocalRange(expense, startOfDay, endOfDay))
        .toList(growable: false);
  }

  List<ExpenseEntry> expensesForWeek(
    DateTime week, {
    int weekStartsOn = DateTime.monday,
  }) {
    final startOfWeek = _startOfWeek(week, weekStartsOn: weekStartsOn);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _expenses
        .where(
          (expense) => _isWithinLocalRange(expense, startOfWeek, endOfWeek),
        )
        .toList(growable: false);
  }

  List<ExpenseEntry> expensesForMonth(DateTime month) {
    final startOfMonth = DateTime(month.toLocal().year, month.toLocal().month);
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1);

    return _expenses
        .where(
          (expense) => _isWithinLocalRange(expense, startOfMonth, endOfMonth),
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

  double totalSpentForWeek(
    DateTime week, {
    int weekStartsOn = DateTime.monday,
  }) {
    return _totalFor(expensesForWeek(week, weekStartsOn: weekStartsOn));
  }

  double totalSpentForMonth(DateTime month) {
    return _totalFor(expensesForMonth(month));
  }

  double totalSpentForCategoryForMonth(DateTime month, String categoryId) {
    return _totalFor(
      expensesForMonth(month)
          .where((expense) {
            return expense.category.id == categoryId;
          })
          .toList(growable: false),
    );
  }

  void addExpense(ExpenseEntry expense) {
    _upsertExpense(expense);
    final uid = _userId;
    if (uid != null) {
      unawaited(
        _expenseService.createExpense(uid, expense).catchError((_) {
          _errorMessage = 'Could not save expense.';
          notifyListeners();
          return expense;
        }),
      );
    }
  }

  Future<ExpenseEntry?> saveExpense(ExpenseEntry expense) async {
    final uid = _userId;
    if (uid == null) {
      _upsertExpense(expense);
      return expense;
    }

    try {
      final savedExpense = await _expenseService.createExpense(uid, expense);
      _upsertExpense(savedExpense);
      return savedExpense;
    } catch (_) {
      _errorMessage = 'Could not save expense.';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateExpense(ExpenseEntry expense) async {
    final previousIndex = _expenses.indexWhere(
      (entry) => entry.id == expense.id,
    );
    final previousExpense = previousIndex >= 0
        ? _expenses[previousIndex]
        : null;
    _upsertExpense(expense);
    final uid = _userId;
    if (uid == null) {
      return true;
    }

    try {
      await _expenseService.updateExpense(uid, expense);
      return true;
    } catch (_) {
      _errorMessage = 'Could not update expense.';
      if (previousExpense != null) {
        _upsertExpense(previousExpense);
      } else {
        _expenses.removeWhere((entry) => entry.id == expense.id);
        notifyListeners();
      }
      return false;
    }
  }

  ExpenseEntry? deleteExpense(String id) {
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index < 0) {
      return null;
    }

    final expense = _expenses.removeAt(index);
    notifyListeners();

    final uid = _userId;
    if (uid != null) {
      late final Future<void> write;
      write = _expenseService
          .softDeleteExpense(uid, id)
          .catchError((_) {
            _errorMessage = 'Could not delete expense.';
            _upsertExpense(expense);
          })
          .whenComplete(() {
            if (identical(_pendingDeleteWrites[id], write)) {
              _pendingDeleteWrites.remove(id);
            }
          });
      _pendingDeleteWrites[id] = write;
      unawaited(write);
    }
    return expense;
  }

  void restoreExpense(ExpenseEntry expense) {
    if (_expenses.any((entry) => entry.id == expense.id)) {
      return;
    }

    _expenses.insert(0, expense);
    notifyListeners();

    final uid = _userId;
    if (uid != null) {
      unawaited(_restoreAfterPendingDelete(uid, expense));
    }
  }

  Future<void> _restoreAfterPendingDelete(
    String uid,
    ExpenseEntry expense,
  ) async {
    try {
      await _pendingDeleteWrites[expense.id];
      await _expenseService.restoreExpense(uid, expense);
    } catch (_) {
      _errorMessage = 'Could not restore expense.';
      notifyListeners();
    }
  }

  void _upsertExpense(ExpenseEntry expense) {
    final index = _expenses.indexWhere((entry) => entry.id == expense.id);
    if (index >= 0) {
      _expenses[index] = expense;
    } else {
      _expenses.insert(0, expense);
    }
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  double _totalFor(List<ExpenseEntry> expenses) {
    return expenses.fold<double>(0, (total, expense) => total + expense.amount);
  }

  DateTime _startOfWeek(DateTime date, {int weekStartsOn = DateTime.monday}) {
    final dateOnly = _startOfLocalDay(date);
    final normalizedStart = weekStartsOn == DateTime.sunday
        ? DateTime.sunday
        : DateTime.monday;
    final delta = (dateOnly.weekday - normalizedStart) % 7;
    return dateOnly.subtract(Duration(days: delta));
  }

  DateTime _startOfLocalDay(DateTime date) {
    final localDate = date.toLocal();
    return DateTime(localDate.year, localDate.month, localDate.day);
  }

  bool _isWithinLocalRange(
    ExpenseEntry expense,
    DateTime inclusiveStart,
    DateTime exclusiveEnd,
  ) {
    final localDate = expense.date.toLocal();
    return !localDate.isBefore(inclusiveStart) &&
        localDate.isBefore(exclusiveEnd);
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}
