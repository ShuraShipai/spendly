import '../../expenses/models/expense_entry.dart';
import '../models/category_spend_summary.dart';

class ReportsProvider {
  const ReportsProvider({required this.expenses});

  final List<ExpenseEntry> expenses;

  MonthlyReportSummary monthlySummary(DateTime referenceDate) {
    final monthlyExpenses = _monthlyExpenses(referenceDate);
    final previousMonthDate = DateTime(
      referenceDate.year,
      referenceDate.month - 1,
    );
    final previousTotal = _total(_monthlyExpenses(previousMonthDate));
    final total = _total(monthlyExpenses);

    return MonthlyReportSummary(
      expenses: monthlyExpenses,
      total: total,
      previousTotal: previousTotal,
      biggestExpense: _biggestExpense(monthlyExpenses),
      dailyAverage: referenceDate.day == 0 ? 0 : total / referenceDate.day,
      categorySummaries: _categorySummaries(monthlyExpenses),
    );
  }

  String monthlyCsv(DateTime referenceDate) {
    final rows = [
      ['Date', 'Category', 'Payment method', 'Amount', 'Currency', 'Note'],
      for (final expense in _monthlyExpenses(referenceDate))
        [
          _dateValue(expense.date),
          expense.category.label,
          expense.paymentMethod.label,
          _amountValue(expense.amount),
          expense.currencyCode,
          expense.note ?? '',
        ],
    ];

    return rows.map(_csvRow).join('\n');
  }

  List<ExpenseEntry> _monthlyExpenses(DateTime referenceDate) {
    return expenses
        .where(
          (expense) =>
              expense.date.year == referenceDate.year &&
              expense.date.month == referenceDate.month,
        )
        .toList(growable: false);
  }

  double _total(List<ExpenseEntry> expenses) {
    return expenses.fold<double>(0, (total, expense) => total + expense.amount);
  }

  ExpenseEntry? _biggestExpense(List<ExpenseEntry> expenses) {
    if (expenses.isEmpty) {
      return null;
    }

    final sorted = [...expenses]..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.first;
  }

  List<CategorySpendSummary> _categorySummaries(List<ExpenseEntry> expenses) {
    final totals = <String, CategorySpendSummary>{};
    for (final expense in expenses) {
      final existing = totals[expense.category.id];
      totals[expense.category.id] = CategorySpendSummary(
        category: expense.category,
        total: (existing?.total ?? 0) + expense.amount,
      );
    }

    return totals.values.toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  String _csvRow(List<String> values) {
    return values.map(_csvValue).join(',');
  }

  String _csvValue(String value) {
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuotes) {
      return value;
    }

    return '"${value.replaceAll('"', '""')}"';
  }

  String _dateValue(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _amountValue(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }

    return amount.toStringAsFixed(2);
  }
}

class MonthlyReportSummary {
  const MonthlyReportSummary({
    required this.expenses,
    required this.total,
    required this.previousTotal,
    required this.biggestExpense,
    required this.dailyAverage,
    required this.categorySummaries,
  });

  final List<ExpenseEntry> expenses;
  final double total;
  final double previousTotal;
  final ExpenseEntry? biggestExpense;
  final double dailyAverage;
  final List<CategorySpendSummary> categorySummaries;
}
