import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NavigationIconButton extends StatelessWidget {
  const NavigationIconButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkInkMuted : AppColors.inkSubtle;

    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(selected ? selectedIcon : icon),
      color: selected ? AppColors.mint : inactiveColor,
      iconSize: 24,
      style: IconButton.styleFrom(
        fixedSize: const Size(54, 54),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
