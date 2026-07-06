import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/settings/services/settings_firestore_service.dart';

void main() {
  group('SettingsFirestoreService memory', () {
    test('saves and loads preferences and budgets', () async {
      final service = SettingsFirestoreService.memory();

      await service.savePreferences(
        'user-1',
        const UserPreferencesData(
          themeMode: 'dark',
          currencyCode: 'USD',
          weekStartsOn: 'sunday',
          budgetAlertsEnabled: false,
        ),
      );
      await service.saveBudget(
        'user-1',
        const UserBudgetData(
          monthlyBudgetCents: 1200000,
          categoryBudgetCents: {'food': 300000},
        ),
      );

      final preferences = await service.loadPreferences('user-1');
      final budget = await service.loadBudget('user-1');

      expect(preferences?.themeMode, 'dark');
      expect(preferences?.currencyCode, 'USD');
      expect(preferences?.weekStartsOn, 'sunday');
      expect(preferences?.budgetAlertsEnabled, isFalse);
      expect(budget?.monthlyBudgetCents, 1200000);
      expect(budget?.categoryBudgetCents['food'], 300000);
    });
  });
}
