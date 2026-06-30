import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/bottom_nav_metrics.dart';
import 'navigation_icon_button.dart';

class SpendlyBottomNavBar extends StatelessWidget {
  const SpendlyBottomNavBar({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.metrics,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final BottomNavMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;
    final borderColor = isDark ? AppColors.darkInkMuted : AppColors.line;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: borderColor.withValues(alpha: 0.28)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: metrics.bottomSafePadding),
        child: SizedBox(
          height: metrics.barHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.horizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavigationIconButton(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  buttonSize: metrics.buttonSize,
                  iconSize: metrics.iconSize,
                  labelSize: metrics.labelSize,
                  onPressed: () => onTabSelected(0),
                ),
                NavigationIconButton(
                  icon: Icons.list_alt_outlined,
                  selectedIcon: Icons.list_alt_rounded,
                  label: 'Transactions',
                  selected: selectedIndex == 1,
                  buttonSize: metrics.buttonSize,
                  iconSize: metrics.iconSize,
                  labelSize: metrics.labelSize,
                  onPressed: () => onTabSelected(1),
                ),
                NavigationIconButton(
                  icon: Icons.trending_up_outlined,
                  selectedIcon: Icons.trending_up_rounded,
                  label: 'Reports',
                  selected: selectedIndex == 2,
                  buttonSize: metrics.buttonSize,
                  iconSize: metrics.iconSize,
                  labelSize: metrics.labelSize,
                  onPressed: () => onTabSelected(2),
                ),
                NavigationIconButton(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Settings',
                  selected: selectedIndex == 3,
                  buttonSize: metrics.buttonSize,
                  iconSize: metrics.iconSize,
                  labelSize: metrics.labelSize,
                  onPressed: () => onTabSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
