import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseSheetHeader extends StatelessWidget {
  const ExpenseSheetHeader({
    required this.title,
    required this.leadingIcon,
    required this.onLeadingPressed,
    super.key,
  });

  final String title;
  final IconData leadingIcon;
  final VoidCallback onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SquareIconButton(icon: leadingIcon, onPressed: onLeadingPressed),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox.square(dimension: 34),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onPressed});

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
