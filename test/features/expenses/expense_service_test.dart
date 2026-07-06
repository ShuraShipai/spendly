import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/expenses/services/expense_service.dart';

void main() {
  group('ExpenseService memory', () {
    test('creates updates soft deletes and restores expenses', () async {
      final service = ExpenseService.memory();
      final expense = ExpenseEntry(
        id: '',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.upi,
      );

      final created = await service.createExpense('user-1', expense);
      expect(created.id, isNotEmpty);
      expect(
        (await service.watchActiveExpenses('user-1').first).single.id,
        created.id,
      );

      final updated = created.copyWith(amount: 180);
      await service.updateExpense('user-1', updated);
      expect(
        (await service.watchActiveExpenses('user-1').first).single.amount,
        180,
      );

      await service.softDeleteExpense('user-1', created.id);
      expect(await service.watchActiveExpenses('user-1').first, isEmpty);

      await service.restoreExpense('user-1', updated);
      expect(
        (await service.watchActiveExpenses('user-1').first).single.id,
        created.id,
      );
    });
  });
}
