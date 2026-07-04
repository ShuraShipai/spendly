import 'package:flutter/material.dart';

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
  ThemeMode _themeMode = ThemeMode.system;
  CurrencyPreference _currency = CurrencyPreference.inr;
  WeekStartPreference _weekStart = WeekStartPreference.monday;
  bool _budgetAlertsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  CurrencyPreference get currency => _currency;
  WeekStartPreference get weekStart => _weekStart;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;

  void setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
  }

  void setCurrency(CurrencyPreference currency) {
    if (_currency == currency) {
      return;
    }

    _currency = currency;
    notifyListeners();
  }

  void setWeekStart(WeekStartPreference weekStart) {
    if (_weekStart == weekStart) {
      return;
    }

    _weekStart = weekStart;
    notifyListeners();
  }

  void setBudgetAlertsEnabled(bool enabled) {
    if (_budgetAlertsEnabled == enabled) {
      return;
    }

    _budgetAlertsEnabled = enabled;
    notifyListeners();
  }
}
