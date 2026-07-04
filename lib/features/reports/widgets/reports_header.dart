import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ReportsHeader extends StatelessWidget {
  const ReportsHeader({required this.monthLabel, super.key});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Insights', style: Theme.of(context).textTheme.headlineSmall),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.card,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isDark ? AppColors.darkInkMuted : AppColors.line,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Row(
              children: [
                Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
