import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../expenses/models/expense_category.dart';
import 'category_budget_row.dart';

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
    final children = <Widget>[];
    for (var index = 0; index < categories.length; index++) {
      final category = categories[index];
      children.add(
        CategoryBudgetRow(
          category: category,
          budget: budgetForCategory(category),
          spent: spentForCategory(category),
          onTap: () => onEditCategory(category),
        ),
      );
      if (index != categories.length - 1) {
        children.add(const SizedBox(height: AppSpacing.sm));
      }
    }

    return Column(children: children);
  }
}
