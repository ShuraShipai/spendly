import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../models/budget_editor_request.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_budgets_editor.dart';
import '../widgets/category_budgets_view.dart';

class CategoryBudgetsScreen extends StatefulWidget {
  const CategoryBudgetsScreen({this.initialEditorRequest, super.key});

  final BudgetEditorRequest? initialEditorRequest;

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
    final month = DateTime.now();
    return CategoryBudgetsEditor(
      initialEditorRequest: widget.initialEditorRequest,
      childBuilder: (context, actions) {
        final categories = settingsProvider.categories;
        final totalSpent = expenseProvider.totalSpentForMonth(month);
        return Scaffold(
          appBar: AppBar(title: const Text('Budgets')),
          body: SafeArea(
            child: CategoryBudgetsView(
              categories: categories,
              budget: settingsProvider.monthlyBudget,
              spent: totalSpent,
              periodLabel: _monthLabel(month),
              isLoadingBudget: settingsProvider.isLoadingBudget,
              isLoadingCategories: settingsProvider.isLoadingCategories,
              budgetForCategory: (category) =>
                  settingsProvider.budgetForCategory(category.id),
              spentForCategory: (category) => expenseProvider
                  .totalSpentForCategoryForMonth(month, category.id),
              onEditMonthlyBudget: () =>
                  actions.editMonthlyBudget(settingsProvider.monthlyBudget),
              onResetCategoryBudgets: actions.resetCategoryBudgets,
              onEditCategory: actions.editCategory,
            ),
          ),
        );
      },
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
