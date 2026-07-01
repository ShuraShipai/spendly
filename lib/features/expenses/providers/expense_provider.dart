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

  void addExpense(ExpenseEntry expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }
}
