import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseSheetIconButton extends StatelessWidget {
  const ExpenseSheetIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.card,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox.square(
          dimension: 34,
          child: Icon(
            icon,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
    );
  }
}
