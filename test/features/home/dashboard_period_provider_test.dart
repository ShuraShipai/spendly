import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/home/models/dashboard_period.dart';
import 'package:spendly/features/home/providers/dashboard_period_provider.dart';

void main() {
  test('defaults dashboard period to today', () {
    final provider = DashboardPeriodProvider();

    expect(provider.selectedPeriod, DashboardPeriod.today);
  });

  test('updates selected dashboard period', () {
    final provider = DashboardPeriodProvider();

    provider.setSelectedPeriod(DashboardPeriod.month);

    expect(provider.selectedPeriod, DashboardPeriod.month);
  });
}
