import 'package:flutter/material.dart';

import '../../features/settings/services/settings_firestore_service.dart';

enum CurrencyPreference {
  inr('₹ INR'),
  usd('\$ USD'),
  eur('€ EUR'),
  gbp('£ GBP');

  const CurrencyPreference(this.label);

  final String label;
}

enum WeekStartPreference {
  monday('Monday'),
  sunday('Sunday');

  const WeekStartPreference(this.label);

  final String label;
}

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({SettingsFirestoreService? settingsService})
    : _settingsService = settingsService ?? SettingsFirestoreService.memory();

  final SettingsFirestoreService _settingsService;
  ThemeMode _themeMode = ThemeMode.system;
  CurrencyPreference _currency = CurrencyPreference.inr;
  WeekStartPreference _weekStart = WeekStartPreference.monday;
  bool _budgetAlertsEnabled = true;
  String? _userId;
  bool _isLoadingPreferences = false;
  String? _errorMessage;

  ThemeMode get themeMode => _themeMode;
  CurrencyPreference get currency => _currency;
  WeekStartPreference get weekStart => _weekStart;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get isLoadingPreferences => _isLoadingPreferences;
  String? get errorMessage => _errorMessage;

  bool isDarkModeActive(Brightness platformBrightness) {
    return switch (_themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
  }

  Future<void> bindUser(String? uid) async {
    if (_userId == uid) {
      return;
    }

    _userId = uid;
    _errorMessage = null;
    _resetPreferences();
    if (uid == null) {
      notifyListeners();
      return;
    }

    _isLoadingPreferences = true;
    notifyListeners();

    try {
      final preferences = await _settingsService.loadPreferences(uid);
      if (_userId != uid) {
        return;
      }
      if (preferences != null) {
        _themeMode = _themeModeFromStorage(preferences.themeMode);
        _currency = _currencyFromStorage(preferences.currencyCode);
        _weekStart = _weekStartFromStorage(preferences.weekStartsOn);
        _budgetAlertsEnabled = preferences.budgetAlertsEnabled;
      } else {
        await _persistPreferences();
      }
    } catch (_) {
      if (_userId != uid) {
        return;
      }
      _errorMessage = 'Could not load preferences.';
    } finally {
      if (_userId == uid) {
        _isLoadingPreferences = false;
        notifyListeners();
      }
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    _persistPreferencesIfBound();
    notifyListeners();
  }

  void setCurrency(CurrencyPreference currency) {
    if (_currency == currency) {
      return;
    }

    _currency = currency;
    _persistPreferencesIfBound();
    notifyListeners();
  }

  void setWeekStart(WeekStartPreference weekStart) {
    if (_weekStart == weekStart) {
      return;
    }

    _weekStart = weekStart;
    _persistPreferencesIfBound();
    notifyListeners();
  }

  void setBudgetAlertsEnabled(bool enabled) {
    if (_budgetAlertsEnabled == enabled) {
      return;
    }

    _budgetAlertsEnabled = enabled;
    _persistPreferencesIfBound();
    notifyListeners();
  }

  void _persistPreferencesIfBound() {
    if (_userId == null) {
      return;
    }
    _persistPreferences();
  }

  Future<void> _persistPreferences() async {
    final uid = _userId;
    if (uid == null) {
      return;
    }

    try {
      await _settingsService.savePreferences(
        uid,
        UserPreferencesData(
          themeMode: _themeMode.name,
          currencyCode: _currency.storageValue,
          weekStartsOn: _weekStart.storageValue,
          budgetAlertsEnabled: _budgetAlertsEnabled,
        ),
      );
      if (_userId == uid) {
        _errorMessage = null;
      }
    } catch (_) {
      if (_userId == uid) {
        _errorMessage = 'Could not save preferences.';
        notifyListeners();
      }
    }
  }

  void _resetPreferences() {
    _themeMode = ThemeMode.system;
    _currency = CurrencyPreference.inr;
    _weekStart = WeekStartPreference.monday;
    _budgetAlertsEnabled = true;
    _isLoadingPreferences = false;
  }

  ThemeMode _themeModeFromStorage(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  CurrencyPreference _currencyFromStorage(String value) {
    for (final currency in CurrencyPreference.values) {
      if (currency.storageValue == value) {
        return currency;
      }
    }
    return CurrencyPreference.inr;
  }

  WeekStartPreference _weekStartFromStorage(String value) {
    for (final weekStart in WeekStartPreference.values) {
      if (weekStart.storageValue == value) {
        return weekStart;
      }
    }
    return WeekStartPreference.monday;
  }
}

extension CurrencyPreferenceStorage on CurrencyPreference {
  String get storageValue {
    return switch (this) {
      CurrencyPreference.inr => 'INR',
      CurrencyPreference.usd => 'USD',
      CurrencyPreference.eur => 'EUR',
      CurrencyPreference.gbp => 'GBP',
    };
  }
}

extension WeekStartPreferenceStorage on WeekStartPreference {
  String get storageValue {
    return switch (this) {
      WeekStartPreference.monday => 'monday',
      WeekStartPreference.sunday => 'sunday',
    };
  }
}
