import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/expenses/providers/expense_provider.dart';
import 'package:spendly/features/expenses/screens/edit_expense_screen.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/settings/providers/settings_provider.dart';

void main() {
  testWidgets('shows saved custom categories when editing an expense', (
    tester,
  ) async {
    final provider = ExpenseProvider();
    final settingsProvider = SettingsProvider(
      categoryService: CustomCategoryService.memory(),
    );
    final currentExpense = ExpenseEntry(
      id: 'coffee',
      amount: 120,
      category: ExpenseCategory.food,
      date: DateTime(2026, 7, 2),
      paymentMethod: PaymentMethod.cash,
    );
    final savedCustomCategory = await settingsProvider.addCustomCategory(
      uid: 'user-1',
      label: 'Office snacks',
    );
    expect(savedCustomCategory, isNotNull);

    provider.addExpense(currentExpense);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const MaterialApp(home: EditExpenseScreen(expenseId: 'coffee')),
      ),
    );

    expect(find.text('Office snacks'), findsOneWidget);

    await tester.tap(find.text('Office snacks'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(provider.expenseById('coffee')?.category, savedCustomCategory);
  });
}
