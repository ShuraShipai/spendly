import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../expenses/widgets/add_expense_flow_sheet.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/navigation_icon_button.dart';
import '../widgets/placeholder_tab.dart';
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
    PlaceholderTab(
      title: 'Transactions',
      subtitle: 'Your expenses will appear here.',
      icon: Icons.list_alt_rounded,
    ),
    PlaceholderTab(
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

  void _showAddExpenseFlow() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (_) => const AddExpenseFlowSheet(),
    );
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
          elevation: 0,
          backgroundColor: AppColors.mint,
          heroTag: 'add-expense',
          onPressed: _showAddExpenseFlow,
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
                  NavigationIconButton(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    selected: _selectedIndex == 0,
                    onPressed: () => _selectTab(0),
                  ),
                  NavigationIconButton(
                    icon: Icons.list_alt_outlined,
                    selectedIcon: Icons.list_alt_rounded,
                    label: 'Transactions',
                    selected: _selectedIndex == 1,
                    onPressed: () => _selectTab(1),
                  ),
                  NavigationIconButton(
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up_rounded,
                    label: 'Reports',
                    selected: _selectedIndex == 2,
                    onPressed: () => _selectTab(2),
                  ),
                  NavigationIconButton(
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
