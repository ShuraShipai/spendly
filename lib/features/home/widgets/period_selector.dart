import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/dashboard_period.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodSelected,
    super.key,
  });

  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;
    final borderColor = isDark ? AppColors.darkInkMuted : AppColors.line;

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: borderColor.withValues(alpha: 0.28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final period in DashboardPeriod.values)
                _PeriodChip(
                  label: period.label,
                  selected: period == selectedPeriod,
                  onTap: () => onPeriodSelected(period),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.mint : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : AppColors.inkSubtle,
            ),
          ),
        ),
      ),
    );
  }
}
