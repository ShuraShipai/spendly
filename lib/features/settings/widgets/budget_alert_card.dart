import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

enum BudgetAlertSeverity { warning, exceeded }

class BudgetAlertCard extends StatelessWidget {
  const BudgetAlertCard({
    required this.severity,
    required this.title,
    required this.message,
    required this.progress,
    this.onAdjustBudget,
    this.onViewExpenses,
    super.key,
  });

  final BudgetAlertSeverity severity;
  final String title;
  final String message;
  final double progress;
  final VoidCallback? onAdjustBudget;
  final VoidCallback? onViewExpenses;

  @override
  Widget build(BuildContext context) {
    final isExceeded = severity == BudgetAlertSeverity.exceeded;
    final accent = isExceeded ? AppColors.danger : AppColors.warning;
    final titleColor = isExceeded
        ? const Color(0xFFC8503C)
        : const Color(0xFF8A6914);
    final bodyColor = isExceeded
        ? const Color(0xFFC8604C)
        : const Color(0xFF9A7A2C);
    final startColor = isExceeded
        ? AppColors.dangerSurface
        : AppColors.warningSurface;
    final endColor = isExceeded
        ? const Color(0xFFFFDDD6)
        : const Color(0xFFFFEAC0);
    final borderColor = isExceeded
        ? const Color(0xFFFFC0B5)
        : const Color(0xFFFFD98A);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: SizedBox.square(
                dimension: 56,
                child: Icon(
                  isExceeded
                      ? Icons.error_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: accent,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: bodyColor, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 9,
                color: accent,
                backgroundColor: AppColors.card,
              ),
            ),
            if (isExceeded &&
                onAdjustBudget != null &&
                onViewExpenses != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _BudgetAlertAction(
                      label: 'Adjust budget',
                      foregroundColor: titleColor,
                      backgroundColor: AppColors.card,
                      onPressed: onAdjustBudget!,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _BudgetAlertAction(
                      label: 'View expenses',
                      foregroundColor: AppColors.card,
                      backgroundColor: AppColors.danger,
                      onPressed: onViewExpenses!,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetAlertAction extends StatelessWidget {
  const _BudgetAlertAction({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: SizedBox(
          height: 42,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foregroundColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
