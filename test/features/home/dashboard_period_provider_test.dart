import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/home/models/dashboard_period.dart';
import 'package:spendly/features/home/providers/dashboard_period_provider.dart';

void main() {
  test('defaults dashboard period to today', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dashboardPeriodProvider), DashboardPeriod.today);
  });
}
