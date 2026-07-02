import 'package:flutter/foundation.dart';

import '../models/expense_entry.dart';

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
