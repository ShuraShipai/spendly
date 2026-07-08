import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/app/providers/app_state_provider.dart';
import 'package:spendly/features/settings/services/settings_firestore_service.dart';

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

    test('resolves system theme against platform brightness', () {
      final provider = AppStateProvider();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.isDarkModeActive(Brightness.light), isFalse);
      expect(provider.isDarkModeActive(Brightness.dark), isTrue);

      provider.setThemeMode(ThemeMode.light);

      expect(provider.isDarkModeActive(Brightness.dark), isFalse);

      provider.setThemeMode(ThemeMode.dark);

      expect(provider.isDarkModeActive(Brightness.light), isTrue);
    });

    test('resets user-specific preferences when unbound', () async {
      final service = _FakeSettingsFirestoreService()
        ..preferences['user-1'] = const UserPreferencesData(
          themeMode: 'dark',
          currencyCode: 'USD',
          weekStartsOn: 'sunday',
          budgetAlertsEnabled: false,
        );
      final provider = AppStateProvider(settingsService: service);

      await provider.bindUser('user-1');

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.currency, CurrencyPreference.usd);
      expect(provider.weekStart, WeekStartPreference.sunday);
      expect(provider.budgetAlertsEnabled, isFalse);

      await provider.bindUser(null);

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.currency, CurrencyPreference.inr);
      expect(provider.weekStart, WeekStartPreference.monday);
      expect(provider.budgetAlertsEnabled, isTrue);
    });

    test('does not let new users inherit prior user preferences', () async {
      final service = _FakeSettingsFirestoreService()
        ..preferences['user-1'] = const UserPreferencesData(
          themeMode: 'dark',
          currencyCode: 'USD',
          weekStartsOn: 'sunday',
          budgetAlertsEnabled: false,
        );
      final provider = AppStateProvider(settingsService: service);

      await provider.bindUser('user-1');
      await provider.bindUser('user-2');

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.currency, CurrencyPreference.inr);
      expect(provider.weekStart, WeekStartPreference.monday);
      expect(provider.budgetAlertsEnabled, isTrue);
      expect(service.savedPreferences['user-2']?.themeMode, 'system');
      expect(service.savedPreferences['user-2']?.currencyCode, 'INR');
      expect(service.savedPreferences['user-2']?.weekStartsOn, 'monday');
      expect(service.savedPreferences['user-2']?.budgetAlertsEnabled, isTrue);
    });
  });
}

class _FakeSettingsFirestoreService extends SettingsFirestoreService {
  _FakeSettingsFirestoreService() : super.memory();

  final preferences = <String, UserPreferencesData?>{};
  final savedPreferences = <String, UserPreferencesData>{};
  final loadCompleters = <String, Completer<UserPreferencesData?>>{};

  @override
  Future<UserPreferencesData?> loadPreferences(String uid) {
    final completer = loadCompleters[uid];
    if (completer != null) {
      return completer.future;
    }

    return Future<UserPreferencesData?>.value(preferences[uid]);
  }

  @override
  Future<void> savePreferences(
    String uid,
    UserPreferencesData preferences,
  ) async {
    savedPreferences[uid] = preferences;
  }
}
