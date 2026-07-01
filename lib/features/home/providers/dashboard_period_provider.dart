import 'package:flutter_riverpod/legacy.dart';

import '../models/dashboard_period.dart';

final dashboardPeriodProvider = StateProvider<DashboardPeriod>(
  (ref) => DashboardPeriod.today,
);
