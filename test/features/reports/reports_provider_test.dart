import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/reports/providers/reports_provider.dart';

void main() {
  test('builds monthly report summary from expenses', () {
    final provider = ReportsProvider(
      expenses: [
        ExpenseEntry(
          id: 'rent',
          amount: 8500,
          category: ExpenseCategory.rent,
          date: DateTime(2026, 7, 1),
          paymentMethod: PaymentMethod.upi,
        ),
        ExpenseEntry(
          id: 'coffee',
          amount: 380,
          category: ExpenseCategory.food,
          date: DateTime(2026, 7, 2),
          paymentMethod: PaymentMethod.card,
          note: 'Coffee, pastry',
        ),
        ExpenseEntry(
          id: 'june-food',
          amount: 500,
          category: ExpenseCategory.food,
          date: DateTime(2026, 6, 30),
          paymentMethod: PaymentMethod.cash,
        ),
      ],
    );

    final summary = provider.monthlySummary(DateTime(2026, 7, 3));

    expect(summary.expenses, hasLength(2));
    expect(summary.total, 8880);
    expect(summary.previousTotal, 500);
    expect(summary.biggestExpense?.id, 'rent');
    expect(summary.dailyAverage, 2960);
    expect(summary.categorySummaries.first.category, ExpenseCategory.rent);
  });

  test('exports monthly expenses as escaped CSV', () {
    final provider = ReportsProvider(
      expenses: [
        ExpenseEntry(
          id: 'coffee',
          amount: 120.5,
          category: ExpenseCategory.food,
          date: DateTime(2026, 7, 2),
          paymentMethod: PaymentMethod.upi,
          note: 'Coffee, "large"',
        ),
        ExpenseEntry(
          id: 'june-food',
          amount: 90,
          category: ExpenseCategory.food,
          date: DateTime(2026, 6, 30),
          paymentMethod: PaymentMethod.cash,
        ),
      ],
    );

    final csv = provider.monthlyCsv(DateTime(2026, 7, 4));

    expect(
      csv,
      [
        'Date,Category,Payment method,Amount,Currency,Note',
        '2026-07-02,Food,UPI,120.50,INR,"Coffee, ""large"""',
      ].join('\n'),
    );
  });
}
