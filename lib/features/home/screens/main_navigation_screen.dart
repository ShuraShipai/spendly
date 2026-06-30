import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../settings/screens/settings_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  var _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    _PlaceholderTab(
      title: 'Transactions',
      subtitle: 'Your expenses will appear here.',
      icon: Icons.list_alt_rounded,
    ),
    _PlaceholderTab(
      title: 'Reports',
      subtitle: 'Charts and spending trends will appear here.',
      icon: Icons.trending_up_rounded,
    ),
    SettingsScreen(),
  ];

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;
    final borderColor = isDark ? AppColors.darkInkMuted : AppColors.line;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: SizedBox.square(
        dimension: 58,
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 0,
          backgroundColor: AppColors.mint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              top: BorderSide(color: borderColor.withValues(alpha: 0.28)),
            ),
          ),
          child: SizedBox(
            height: 62,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIconButton(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    selected: _selectedIndex == 0,
                    onPressed: () => _selectTab(0),
                  ),
                  _NavIconButton(
                    icon: Icons.list_alt_outlined,
                    selectedIcon: Icons.list_alt_rounded,
                    label: 'Transactions',
                    selected: _selectedIndex == 1,
                    onPressed: () => _selectTab(1),
                  ),
                  _NavIconButton(
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up_rounded,
                    label: 'Reports',
                    selected: _selectedIndex == 2,
                    onPressed: () => _selectTab(2),
                  ),
                  _NavIconButton(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Settings',
                    selected: _selectedIndex == 3,
                    onPressed: () => _selectTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onPressed,
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.mint, size: 54),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
