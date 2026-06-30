import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NavigationIconButton extends StatelessWidget {
  const NavigationIconButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.buttonSize = 54,
    this.iconSize = 24,
    this.labelSize = 11,
    super.key,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final double buttonSize;
  final double iconSize;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkInkMuted : AppColors.inkSubtle;

    return TooltipTheme(
      data: TooltipThemeData(textStyle: TextStyle(fontSize: labelSize)),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: IconButton(
          tooltip: label,
          onPressed: onPressed,
          icon: Icon(selected ? selectedIcon : icon),
          color: selected ? AppColors.mint : inactiveColor,
          iconSize: iconSize,
          style: IconButton.styleFrom(
            fixedSize: Size.square(buttonSize),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
