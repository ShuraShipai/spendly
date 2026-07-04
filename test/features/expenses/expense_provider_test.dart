import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/expense_sort_option.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/expenses/providers/expense_provider.dart';

void main() {
  group('ExpenseProvider', () {
    test('filters expenses and totals by day week and month', () {
      final provider = ExpenseProvider();
      final july = DateTime(2026, 7);
      final julySecond = DateTime(2026, 7, 2);

      provider.addExpense(
        ExpenseEntry(
          id: 'july-food',
          amount: 120,
          category: ExpenseCategory.food,
          date: DateTime(2026, 7, 2),
          paymentMethod: PaymentMethod.cash,
        ),
      );
      provider.addExpense(
        ExpenseEntry(
          id: 'july-bills',
          amount: 300,
          category: ExpenseCategory.bills,
          date: DateTime(2026, 7, 15),
          paymentMethod: PaymentMethod.upi,
        ),
      );
      provider.addExpense(
        ExpenseEntry(
          id: 'june-food',
          amount: 90,
          category: ExpenseCategory.food,
          date: DateTime(2026, 6, 30),
          paymentMethod: PaymentMethod.cash,
        ),
      );

      expect(provider.expensesForDay(julySecond), hasLength(1));
      expect(provider.totalSpentForDay(julySecond), 120);
      expect(provider.expensesForWeek(julySecond), hasLength(2));
      expect(provider.totalSpentForWeek(julySecond), 210);
      expect(provider.expensesForMonth(july), hasLength(2));
      expect(provider.totalSpentForMonth(july), 420);
    });

    test('updates and deletes existing expenses by id', () {
      final provider = ExpenseProvider();
      final expense = ExpenseEntry(
        id: 'gym',
        amount: 500,
        category: ExpenseCategory.health,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.upi,
      );

      provider.addExpense(expense);
      provider.updateExpense(
        expense.copyWith(amount: 750, note: 'Monthly membership'),
      );

      expect(provider.expenseById('gym')?.amount, 750);
      expect(provider.expenseById('gym')?.displayTitle, 'Monthly membership');

      provider.deleteExpense('gym');

      expect(provider.expenseById('gym'), isNull);
      expect(provider.expenses, isEmpty);
    });

    test('restores a deleted expense for undo', () {
      final provider = ExpenseProvider();
      final expense = ExpenseEntry(
        id: 'coffee',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.cash,
      );

      provider.addExpense(expense);

      final deletedExpense = provider.deleteExpense('coffee');

      expect(deletedExpense, expense);
      expect(provider.expenses, isEmpty);

      provider.restoreExpense(deletedExpense!);

      expect(provider.expenses, [expense]);

      provider.restoreExpense(expense);

      expect(provider.expenses, [expense]);
    });

    test('derives visible sorted expenses and day groups', () {
      final provider = ExpenseProvider();
      final coffee = ExpenseEntry(
        id: 'coffee',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.upi,
        note: 'Coffee',
      );
      final rent = ExpenseEntry(
        id: 'rent',
        amount: 8500,
        category: ExpenseCategory.rent,
        date: DateTime(2026, 7, 1),
        paymentMethod: PaymentMethod.card,
      );

      provider.addExpense(coffee);
      provider.addExpense(rent);

      final visible = provider.visibleExpenses(
        query: 'coffee',
        sortOption: ExpenseSortOption.highestAmount,
        selectedPaymentMethods: {PaymentMethod.upi},
        minAmount: 0,
        maxAmount: 2000,
      );

      expect(visible, [coffee]);
      expect(
        provider.filterLabels(
          selectedCategoryIds: {ExpenseCategory.food.id},
          selectedPaymentMethods: {PaymentMethod.upi},
        ),
        ['Food', 'UPI'],
      );

      final groups = provider.groupByDay(provider.expenses);
      expect(groups, hasLength(2));
      expect(groups.first.date, DateTime(2026, 7, 2));
      expect(groups.first.total, 120);
    });
  });
}
