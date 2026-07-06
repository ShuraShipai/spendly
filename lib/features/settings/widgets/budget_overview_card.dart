import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    required this.budget,
    required this.spent,
    required this.periodLabel,
    super.key,
  });

  final double budget;
  final double spent;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLimit = budget > 0;
    final percent = hasLimit ? (spent / budget * 100).round() : 0;
    final remaining = hasLimit
        ? (budget - spent).clamp(0, double.infinity).toDouble()
        : 0.0;
    final progress = hasLimit ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.darkInkMuted : AppColors.line).withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall · $periodLabel',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  hasLimit ? '$percent%' : 'No limit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: hasLimit && percent >= 90
                        ? AppColors.danger
                        : AppColors.mintDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge,
                children: [
                  if (hasLimit) ...[
                    TextSpan(text: _formatAmount(spent)),
                    TextSpan(
                      text: ' / ${_formatAmount(budget)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSubtle,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ] else
                    const TextSpan(text: 'No limit'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                height: 11,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.mintTintStrong,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mint, AppColors.mintDark],
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasLimit
                  ? '${_formatAmount(remaining)} left · ${progress >= 0.9 ? 'review soon' : 'on track'}'
                  : 'No limit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkSubtle,
                fontWeight: FontWeight.w700,
              ),
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
