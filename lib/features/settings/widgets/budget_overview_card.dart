import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    required this.budget,
    required this.spent,
    required this.alertsEnabled,
    required this.onEdit,
    super.key,
  });

  final double budget;
  final double spent;
  final bool alertsEnabled;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = (budget - spent).clamp(0, double.infinity).toDouble();
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: (isDark ? AppColors.darkInkMuted : AppColors.line).withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monthly budget',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatAmount(remaining),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'left from ${_formatAmount(budget)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: progress >= 0.9 ? AppColors.danger : AppColors.mint,
                backgroundColor: AppColors.line.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatAmount(spent)} spent',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  alertsEnabled ? 'Alerts on' : 'Alerts off',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: alertsEnabled
                        ? AppColors.mintDark
                        : AppColors.inkSubtle,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
