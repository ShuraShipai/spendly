import 'package:flutter/material.dart';

import '../../expenses/widgets/add_expense_flow_sheet.dart';
import '../../settings/screens/settings_screen.dart';
import '../models/bottom_nav_metrics.dart';
import '../widgets/add_expense_fab.dart';
import '../widgets/placeholder_tab.dart';
import '../widgets/spendly_bottom_nav_bar.dart';
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
    final metrics = BottomNavMetrics.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: AddExpenseFab(
        metrics: metrics,
        onPressed: _showAddExpenseFlow,
      ),
      floatingActionButtonLocation: SpendlyFabLocation(metrics),
      bottomNavigationBar: SpendlyBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _selectTab,
        metrics: metrics,
      ),
    );
  }
}
