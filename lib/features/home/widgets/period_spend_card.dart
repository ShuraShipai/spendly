import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard_period.dart';

class PeriodSpendCard extends StatelessWidget {
  const PeriodSpendCard({
    required this.totalSpent,
    required this.period,
    required this.referenceDate,
    super.key,
  });

  final double totalSpent;
  final DashboardPeriod period;
  final DateTime referenceDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [AppColors.darkSurface, Color(0xFF16221F)]
        : const [AppColors.mintTint, AppColors.card];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.mintTintStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              period.totalLabel,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatAmount(totalSpent),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              totalSpent == 0
                  ? 'Add expenses to see ${_periodName()} grow'
                  : '${_periodName()} dashboard is live.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _periodName() {
    return switch (period) {
      DashboardPeriod.today => 'today',
      DashboardPeriod.week => 'this week',
      DashboardPeriod.month => _monthName(referenceDate),
    };
  }

  String _monthName(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return monthNames[date.month - 1];
  }
}
