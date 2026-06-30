import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

class EmptyExpenseState extends StatelessWidget {
  const EmptyExpenseState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PennyEmptyMark(),
        const SizedBox(height: AppSpacing.sm),
        Text('No expenses yet', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tap the + button to log your first one. It takes 10 seconds.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PennyEmptyMark extends StatelessWidget {
  const _PennyEmptyMark();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.mintTint;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
        boxShadow: isDark ? null : AppShadows.soft,
      ),
      child: SizedBox.square(
        dimension: 96,
        child: Center(
          child: Text(
            '₹',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.mint),
          ),
        ),
      ),
    );
  }
}
