import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseDetailHeader extends StatelessWidget {
  const ExpenseDetailHeader({
    required this.onBack,
    required this.onDelete,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onDelete;

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
        _IconBox(icon: Icons.more_vert_rounded, onTap: onDelete),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isDark ? AppColors.darkInkMuted : AppColors.line,
          ),
        ),
        child: SizedBox.square(dimension: 34, child: Icon(icon, size: 18)),
      ),
    );
  }
}
