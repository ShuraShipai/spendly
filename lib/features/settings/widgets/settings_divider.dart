import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkInkMuted : AppColors.line;

    return Divider(
      height: 1,
      thickness: 1,
      indent: AppSpacing.lg,
      color: color.withValues(alpha: 0.22),
    );
  }
}
