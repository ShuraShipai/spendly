import 'expense_entry.dart';

class ExpenseDayGroup {
  const ExpenseDayGroup({required this.date, required this.expenses});

  final DateTime date;
  final List<ExpenseEntry> expenses;

  double get total {
    return expenses.fold<double>(0, (total, expense) => total + expense.amount);
  }
}
