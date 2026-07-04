import 'package:flutter/foundation.dart';

import '../models/dashboard_period.dart';

class DashboardPeriodProvider extends ChangeNotifier {
  var _selectedPeriod = DashboardPeriod.today;

  DashboardPeriod get selectedPeriod => _selectedPeriod;

  void setSelectedPeriod(DashboardPeriod period) {
    if (_selectedPeriod == period) {
      return;
    }

    _selectedPeriod = period;
    notifyListeners();
  }
}
