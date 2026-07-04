import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({
    required this.label,
    required this.value,
    required this.caption,
    super.key,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? AppColors.darkInkMuted : AppColors.line,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.inkSubtle),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              caption,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
