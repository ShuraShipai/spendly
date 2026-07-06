import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/budget_amount_sheet.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/category_budget_list.dart';
import '../widgets/settings_section_header.dart';

class CategoryBudgetsScreen extends StatefulWidget {
  const CategoryBudgetsScreen({super.key});

  @override
  State<CategoryBudgetsScreen> createState() => _CategoryBudgetsScreenState();
}

class _CategoryBudgetsScreenState extends State<CategoryBudgetsScreen> {
  String? _loadedCategoryUserId;
  var _hasLoadedCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().user?.uid;
    if (_hasLoadedCategories && _loadedCategoryUserId == uid) {
      return;
    }

    _loadedCategoryUserId = uid;
    _hasLoadedCategories = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final settingsProvider = context.read<SettingsProvider>();
      unawaited(settingsProvider.loadCategories(uid));
      unawaited(settingsProvider.loadBudget(uid));
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final categories = settingsProvider.categories;
    final month = DateTime.now();
    final monthExpenses = expenseProvider.expensesForMonth(month);
    final totalSpent = monthExpenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text('Budgets', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            BudgetOverviewCard(
              budget: settingsProvider.monthlyBudget,
              spent: totalSpent,
              periodLabel: _monthLabel(month),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              label: 'Edit budgets',
              onPressed: () =>
                  _showMonthlyBudgetActions(settingsProvider.monthlyBudget),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (categories.isNotEmpty) ...[
              SettingsSectionHeader(
                title: 'PER CATEGORY',
                actionLabel: 'Reset',
                onAction: _resetCategoryBudgets,
              ),
              const SizedBox(height: 10),
              CategoryBudgetList(
                categories: categories,
                budgetForCategory: (category) =>
                    settingsProvider.budgetForCategory(category.id),
                spentForCategory: (category) =>
                    _spentForCategory(expenseProvider, category),
                onEditCategory: (category) => _showBudgetSheet(
                  title: '${category.label} budget',
                  initialAmount: settingsProvider.budgetForCategory(
                    category.id,
                  ),
                  onSave: (amount) => context
                      .read<SettingsProvider>()
                      .setCategoryBudget(category.id, amount),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  void _resetCategoryBudgets() {
    context.read<SettingsProvider>().resetCategoryBudgets();
  }

  void _showMonthlyBudgetActions(double currentBudget) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly budget',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              if (currentBudget <= 0)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set limit'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBudgetSheet(
                      title: 'Monthly budget',
                      initialAmount: currentBudget,
                      onSave: context.read<SettingsProvider>().setMonthlyBudget,
                    );
                  },
                )
              else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Edit limit'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showBudgetSheet(
                      title: 'Monthly budget',
                      initialAmount: currentBudget,
                      onSave: context.read<SettingsProvider>().setMonthlyBudget,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reset to unlimited'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<SettingsProvider>().setMonthlyBudget(0);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _spentForCategory(
    ExpenseProvider expenseProvider,
    ExpenseCategory category,
  ) {
    return expenseProvider
        .expensesForMonth(DateTime.now())
        .where((expense) => expense.category.id == category.id)
        .fold<double>(0, (total, expense) => total + expense.amount);
  }

  void _showBudgetSheet({
    required String title,
    required double initialAmount,
    required ValueChanged<double> onSave,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BudgetAmountSheet(
        title: title,
        initialAmount: initialAmount,
        onSave: onSave,
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const labels = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return labels[date.month - 1];
  }
}
