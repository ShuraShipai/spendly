import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/app/providers/app_state_provider.dart';

void main() {
  group('AppStateProvider', () {
    test('updates settings preferences and notifies listeners', () {
      final provider = AppStateProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider
        ..setThemeMode(ThemeMode.dark)
        ..setCurrency(CurrencyPreference.usd)
        ..setWeekStart(WeekStartPreference.sunday)
        ..setBudgetAlertsEnabled(false);

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.currency, CurrencyPreference.usd);
      expect(provider.weekStart, WeekStartPreference.sunday);
      expect(provider.budgetAlertsEnabled, isFalse);
      expect(notifications, 4);
    });

    test('does not notify when setting existing values', () {
      final provider = AppStateProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider
        ..setThemeMode(ThemeMode.system)
        ..setCurrency(CurrencyPreference.inr)
        ..setWeekStart(WeekStartPreference.monday)
        ..setBudgetAlertsEnabled(true);

      expect(notifications, 0);
    });
  });
}
