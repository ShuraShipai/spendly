import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/budget_amount_sheet.dart';
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
      unawaited(context.read<SettingsProvider>().loadCategories(uid));
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final categories = settingsProvider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Category Budgets')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            SettingsSectionHeader(
              title: 'CATEGORY BUDGETS',
              actionLabel: 'Reset',
              onAction: _resetCategoryBudgets,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (settingsProvider.isLoadingCategories) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: AppSpacing.sm),
            ],
            CategoryBudgetList(
              categories: categories,
              budgetForCategory: (category) =>
                  settingsProvider.budgetForCategory(category.id),
              spentForCategory: (category) =>
                  _spentForCategory(expenseProvider, category),
              onEditCategory: (category) => _showBudgetSheet(
                title: '${category.label} budget',
                initialAmount: settingsProvider.budgetForCategory(category.id),
                onSave: (amount) => context
                    .read<SettingsProvider>()
                    .setCategoryBudget(category.id, amount),
              ),
            ),
          ],
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

  void _resetCategoryBudgets() {
    final settingsProvider = context.read<SettingsProvider>();
    for (final category in settingsProvider.categories) {
      settingsProvider.setCategoryBudget(category.id, 0);
    }
  }
}
