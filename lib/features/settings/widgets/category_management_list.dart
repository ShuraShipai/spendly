import 'package:flutter/material.dart';

import '../../expenses/models/expense_category.dart';
import 'category_management_row.dart';
import 'settings_divider.dart';
import 'settings_section.dart';

class CategoryManagementList extends StatelessWidget {
  const CategoryManagementList({
    required this.categories,
    required this.onDeleteCategory,
    super.key,
  });

  final List<ExpenseCategory> categories;
  final ValueChanged<ExpenseCategory> onDeleteCategory;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      children: [
        for (final category in categories) ...[
          CategoryManagementRow(
            category: category,
            onDelete: category.isCustom
                ? () => onDeleteCategory(category)
                : null,
          ),
          if (category != categories.last) const SettingsDivider(),
        ],
      ],
    );
  }
}
