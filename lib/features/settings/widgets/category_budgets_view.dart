import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../expenses/models/expense_category.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/category_budget_list.dart';
import '../widgets/settings_section_header.dart';

class CategoryBudgetsView extends StatelessWidget {
  const CategoryBudgetsView({
    required this.categories,
    required this.budget,
    required this.spent,
    required this.periodLabel,
    required this.isLoadingBudget,
    required this.isLoadingCategories,
    required this.budgetForCategory,
    required this.spentForCategory,
    required this.onEditMonthlyBudget,
    required this.onResetCategoryBudgets,
    required this.onEditCategory,
    super.key,
  });

  final List<ExpenseCategory> categories;
  final double budget;
  final double spent;
  final String periodLabel;
  final bool isLoadingBudget;
  final bool isLoadingCategories;
  final double Function(ExpenseCategory category) budgetForCategory;
  final double Function(ExpenseCategory category) spentForCategory;
  final VoidCallback onEditMonthlyBudget;
  final VoidCallback onResetCategoryBudgets;
  final ValueChanged<ExpenseCategory> onEditCategory;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
          budget: budget,
          spent: spent,
          periodLabel: periodLabel,
        ),
        const SizedBox(height: AppSpacing.md),
        AppPrimaryButton(label: 'Edit budgets', onPressed: onEditMonthlyBudget),
        const SizedBox(height: AppSpacing.lg),
        if (isLoadingBudget || isLoadingCategories) ...[
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: AppSpacing.md),
        ],
        if (categories.isNotEmpty) ...[
          SettingsSectionHeader(
            title: 'PER CATEGORY',
            actionLabel: 'Reset',
            onAction: onResetCategoryBudgets,
          ),
          const SizedBox(height: 10),
          CategoryBudgetList(
            categories: categories,
            budgetForCategory: budgetForCategory,
            spentForCategory: spentForCategory,
            onEditCategory: onEditCategory,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
