import 'package:flutter/material.dart';

import '../features/expenses/screens/expense_list_screen.dart';
import '../features/expenses/widgets/add_expense_flow_sheet.dart';
import '../features/home/models/bottom_nav_metrics.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/widgets/add_expense_fab.dart';
import '../features/home/widgets/spendly_bottom_nav_bar.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  var _selectedIndex = 0;
  var _isExpenseSearchActive = false;
  var _expenseTemporaryStateResetToken = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      if (_selectedIndex == 1) {
        _expenseTemporaryStateResetToken++;
        _isExpenseSearchActive = false;
      }
      _selectedIndex = index;
    });
  }

  void _setExpenseSearchActive(bool value) {
    if (_isExpenseSearchActive == value) {
      return;
    }
    setState(() => _isExpenseSearchActive = value);
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
    final shouldShowFab = !(_selectedIndex == 1 && _isExpenseSearchActive);
    final screens = [
      const HomeScreen(),
      ExpenseListScreen(
        temporaryStateResetToken: _expenseTemporaryStateResetToken,
        onSearchModeChanged: _setExpenseSearchActive,
      ),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      floatingActionButton: shouldShowFab
          ? AddExpenseFab(metrics: metrics, onPressed: _showAddExpenseFlow)
          : null,
      floatingActionButtonLocation: SpendlyFabLocation(metrics),
      bottomNavigationBar: SpendlyBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _selectTab,
        metrics: metrics,
      ),
    );
  }
}
