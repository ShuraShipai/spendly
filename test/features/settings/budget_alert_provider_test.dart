import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/app/providers/app_state_provider.dart';
import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/expenses/providers/expense_provider.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/settings/providers/budget_alert_provider.dart';
import 'package:spendly/features/settings/services/budget_local_notification_service.dart';
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

    test('fires once for an active overall threshold crossing', () {
      final notifications = _FakeBudgetLocalNotificationService();
      final alerts = BudgetAlertProvider(
        localNotificationService: notifications,
      );
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
      expect(notifications.sent, hasLength(1));

      settings.setMonthlyBudget(110);
      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert, isNull);
      expect(notifications.sent, hasLength(1));

      settings.setMonthlyBudget(200);
      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert, isNull);
      expect(notifications.sent, hasLength(1));

      settings.setMonthlyBudget(140);
      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert?.type, BudgetExceededAlertType.overall);
      expect(alerts.pendingAlert?.title, 'Heads up — 86% used');
      expect(
        alerts.pendingAlert?.message,
        'You\'ve spent ₹120 of your ₹140 Overall budget this month.',
      );
      expect(notifications.sent, hasLength(2));
      expect(notifications.sent.last.title, 'Heads up — 86% used');
      expect(
        notifications.sent.last.body,
        'You\'ve spent ₹120 of your ₹140 Overall budget this month.',
      );
    });

    test('fires once for custom category threshold crossing', () async {
      final notifications = _FakeBudgetLocalNotificationService();
      final alerts = BudgetAlertProvider(
        localNotificationService: notifications,
      );
      final expenses = ExpenseProvider();
      final settings = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );
      final month = DateTime(2026, 7);
      final coffee = await settings.addCustomCategory(
        uid: 'user-1',
        label: 'Coffee',
      );

      settings.setCategoryBudget(coffee!.id, 1000);
      expenses.addExpense(
        ExpenseEntry(
          id: 'coffee-1',
          amount: 799,
          category: coffee,
          date: month,
          paymentMethod: PaymentMethod.upi,
        ),
      );

      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert, isNull);
      expect(notifications.sent, isEmpty);

      expenses.addExpense(
        ExpenseEntry(
          id: 'coffee-2',
          amount: 1,
          category: coffee,
          date: month,
          paymentMethod: PaymentMethod.upi,
        ),
      );
      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert?.type, BudgetExceededAlertType.category);
      expect(alerts.pendingAlert?.category, coffee);
      expect(alerts.pendingAlert?.title, 'Heads up — 80% used');
      expect(
        alerts.pendingAlert?.message,
        'You\'ve spent ₹800 of your ₹1000 Coffee budget this month.',
      );
      expect(notifications.sent, hasLength(1));
      expect(notifications.sent.single.title, 'Heads up — 80% used');
      expect(
        notifications.sent.single.body,
        'You\'ve spent ₹800 of your ₹1000 Coffee budget this month.',
      );

      alerts.markAlertShown(alerts.pendingAlert!.id);
      expenses.addExpense(
        ExpenseEntry(
          id: 'coffee-3',
          amount: 200,
          category: coffee,
          date: month,
          paymentMethod: PaymentMethod.upi,
        ),
      );
      alerts.updateAlerts(
        alertsEnabled: true,
        expenseProvider: expenses,
        settingsProvider: settings,
        referenceDate: month,
      );

      expect(alerts.pendingAlert, isNull);
      expect(notifications.sent, hasLength(1));
    });

    test('exposes active threshold alerts for notification screens', () {
      final alerts = BudgetAlertProvider();
      final expenses = ExpenseProvider();
      final settings = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );
      final month = DateTime(2026, 7);

      settings
        ..setMonthlyBudget(100)
        ..setCategoryBudget(ExpenseCategory.food.id, 50);
      expenses.addExpense(
        ExpenseEntry(
          id: 'food',
          amount: 80,
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

      expect(alerts.activeAlerts, hasLength(2));
      expect(alerts.activeAlerts.first.type, BudgetExceededAlertType.overall);
      expect(alerts.activeAlerts.first.title, 'Heads up — 80% used');
      expect(alerts.activeAlerts.last.type, BudgetExceededAlertType.category);
      expect(alerts.activeAlerts.last.title, 'Heads up — 160% used');
    });

    test(
      'updates active alert content when the alert state id stays the same',
      () {
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
            amount: 90,
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

        expect(alerts.activeAlerts.single.title, 'Heads up — 90% used');

        settings.setMonthlyBudget(110);
        alerts.updateAlerts(
          alertsEnabled: true,
          expenseProvider: expenses,
          settingsProvider: settings,
          referenceDate: month,
        );

        expect(alerts.activeAlerts.single.title, 'Heads up — 82% used');
        expect(
          alerts.activeAlerts.single.message,
          'You\'ve spent ₹90 of your ₹110 Overall budget this month.',
        );
      },
    );

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
      expect(alerts.activeAlerts, isEmpty);
    });
  });
}

class _FakeBudgetLocalNotificationService
    implements BudgetLocalNotificationService {
  final sent = <_SentNotification>[];

  @override
  Future<void> showBudgetThresholdAlert({
    required String id,
    required String title,
    required String body,
  }) async {
    sent.add(_SentNotification(id: id, title: title, body: body));
  }
}

class _SentNotification {
  const _SentNotification({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}
