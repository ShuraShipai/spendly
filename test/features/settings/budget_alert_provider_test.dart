import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/app/providers/app_state_provider.dart';
import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/expenses/providers/expense_provider.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/settings/providers/budget_alert_provider.dart';
import 'package:spendly/features/settings/providers/settings_provider.dart';

void main() {
  group('BudgetAlertProvider', () {
    test('queues overall and category exceeded alerts', () {
      final alerts = BudgetAlertProvider();
      final expenses = ExpenseProvider();
      final settings = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );
      final month = DateTime(2026, 7);

      settings
        ..setMonthlyBudget(100)
        ..setCategoryBudget(ExpenseCategory.food.id, 40);
      expenses.addExpense(
        ExpenseEntry(
          id: 'food',
          amount: 120,
          category: ExpenseCategory.food,
          date: month,
          paymentMethod: PaymentMethod.cash,
        ),
      );

      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert?.type, BudgetExceededAlertType.overall);

      alerts.markAlertShown(alerts.pendingAlert!.id);

      expect(alerts.pendingAlert?.type, BudgetExceededAlertType.category);
      expect(alerts.pendingAlert?.category, ExpenseCategory.food);
    });

    test('does not repeat an acknowledged active exceeded state', () {
      final alerts = BudgetAlertProvider();
      final expenses = ExpenseProvider();
      final settings = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );
      final month = DateTime(2026, 7);

      settings.setMonthlyBudget(100);
      expenses.addExpense(
        ExpenseEntry(
          id: 'rent',
          amount: 120,
          category: ExpenseCategory.rent,
          date: month,
          paymentMethod: PaymentMethod.card,
        ),
      );

      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );
      alerts.markAlertShown(alerts.pendingAlert!.id);

      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert, isNull);

      settings.setMonthlyBudget(110);
      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert?.type, BudgetExceededAlertType.overall);
    });

    test('clears pending alerts when budget alerts are disabled', () {
      final alerts = BudgetAlertProvider();
      final appState = AppStateProvider();
      final expenses = ExpenseProvider();
      final settings = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );
      final month = DateTime(2026, 7);

      settings.setMonthlyBudget(100);
      expenses.addExpense(
        ExpenseEntry(
          id: 'rent',
          amount: 120,
          category: ExpenseCategory.rent,
          date: month,
          paymentMethod: PaymentMethod.card,
        ),
      );
      appState.setBudgetAlertsEnabled(false);

      alerts.updateAlerts(
        alertsEnabled: appState.budgetAlertsEnabled,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert, isNull);
    });
  });
}
