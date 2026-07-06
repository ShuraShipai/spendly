import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'expense_theme.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive
              ? ExpenseTheme.mintContainer(context)
              : ExpenseTheme.surface(context),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive ? AppColors.mint : ExpenseTheme.outline(context),
          ),
        ),
        child: SizedBox.square(
          dimension: 34,
          child: Icon(
            icon,
            size: 17,
            color: isActive ? ExpenseTheme.onMintContainer(context) : null,
          ),
        ),
      ),
    );
  }
}
