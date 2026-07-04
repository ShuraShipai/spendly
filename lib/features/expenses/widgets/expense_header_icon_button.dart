import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseHeaderIconButton extends StatelessWidget {
  const ExpenseHeaderIconButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.mintTint
              : isDark
              ? AppColors.darkSurface
              : AppColors.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive
                ? AppColors.mint
                : isDark
                ? AppColors.darkInkMuted
                : AppColors.line,
          ),
        ),
        child: SizedBox.square(
          dimension: 34,
          child: Icon(
            icon,
            size: 17,
            color: isActive ? AppColors.mintDark : null,
          ),
        ),
      ),
    );
  }
}
