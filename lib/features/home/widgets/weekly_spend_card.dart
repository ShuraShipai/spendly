import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class WeeklySpendCard extends StatelessWidget {
  const WeeklySpendCard({required this.totalSpent, super.key});

  final double totalSpent;

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
              'SPENT THIS WEEK',
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
                  ? 'Add expenses to see your total grow'
                  : 'Nice. Your dashboard is live.',
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
}
