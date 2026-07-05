import 'package:flutter/material.dart';

import '../../expenses/models/expense_category.dart';
import 'category_budget_row.dart';
import 'settings_divider.dart';
import 'settings_section.dart';

class CategoryBudgetList extends StatelessWidget {
  const CategoryBudgetList({
    required this.categories,
    required this.budgetForCategory,
    required this.spentForCategory,
    required this.onEditCategory,
    super.key,
  });

  final List<ExpenseCategory> categories;
  final double Function(ExpenseCategory category) budgetForCategory;
  final double Function(ExpenseCategory category) spentForCategory;
  final ValueChanged<ExpenseCategory> onEditCategory;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      children: [
        for (final category in categories) ...[
          CategoryBudgetRow(
            category: category,
            budget: budgetForCategory(category),
            spent: spentForCategory(category),
            onTap: () => onEditCategory(category),
          ),
          if (category != categories.last) const SettingsDivider(),
        ],
      ],
    );
  }
}
