import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseHeaderIconBox extends StatelessWidget {
  const ExpenseHeaderIconBox({required this.icon, this.onTap, super.key});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconBox = DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isDark ? AppColors.darkInkMuted : AppColors.line,
        ),
      ),
      child: SizedBox.square(dimension: 34, child: Icon(icon, size: 18)),
    );

    if (onTap == null) {
      return iconBox;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: iconBox,
    );
  }
}
