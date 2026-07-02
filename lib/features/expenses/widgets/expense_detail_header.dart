import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseDetailHeader extends StatelessWidget {
  const ExpenseDetailHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon: Icons.chevron_left_rounded, onTap: onBack),
        Expanded(
          child: Text(
            'Expense',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox.square(dimension: 34),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, this.onTap});

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
