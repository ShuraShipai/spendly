import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import 'category_picker_tile.dart';
import 'custom_category_name_dialog.dart';
import 'expense_sheet_frame.dart';
import 'expense_sheet_header.dart';
import 'mint_action_button.dart';

class CategoryPickerStep extends StatefulWidget {
  const CategoryPickerStep({
    required this.categories,
    required this.selectedCategory,
    required this.onBack,
    required this.onCategorySelected,
    required this.onCreateCategory,
    super.key,
  });

  final List<ExpenseCategory> categories;
  final ExpenseCategory selectedCategory;
  final VoidCallback onBack;
  final ValueChanged<ExpenseCategory> onCategorySelected;
  final Future<ExpenseCategory> Function(String label) onCreateCategory;

  @override
  State<CategoryPickerStep> createState() => _CategoryPickerStepState();
}

class _CategoryPickerStepState extends State<CategoryPickerStep> {
  final _searchController = TextEditingController();
  final _gridController = ScrollController();
  var _query = '';
  var _creating = false;

  @override
  void dispose() {
    _searchController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  List<ExpenseCategory> get _filteredCategories {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return widget.categories;
    }

    return widget.categories
        .where(
          (category) => category.label.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  Future<void> _createCategory(String label) async {
    if (label.isEmpty || _creating) {
      return;
    }

    setState(() => _creating = true);
    final category = await widget.onCreateCategory(label);
    if (!mounted) {
      return;
    }
    widget.onCategorySelected(category);
  }

  Future<void> _handleAddCategory() async {
    final label = await showDialog<String>(
      context: context,
      builder: (context) {
        return CustomCategoryNameDialog(initialName: _query.trim());
      },
    );

    if (!mounted || label == null) {
      return;
    }

    final normalizedLabel = label.trim().toLowerCase();
    final matchingCategory = _matchingCategoryFor(normalizedLabel);
    if (matchingCategory != null) {
      widget.onCategorySelected(matchingCategory);
      return;
    }

    await _createCategory(label.trim());
  }

  ExpenseCategory? _matchingCategoryFor(String normalizedLabel) {
    for (final category in widget.categories) {
      if (category.label.toLowerCase() == normalizedLabel) {
        return category;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories;

    return ExpenseSheetFrame(
      child: Column(
        children: [
          ExpenseSheetHeader(
            title: 'Pick a category',
            leadingIcon: Icons.chevron_left_rounded,
            onLeadingPressed: widget.onBack,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search categories',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.inkSubtle,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.line, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Scrollbar(
              controller: _gridController,
              thumbVisibility: true,
              child: GridView.count(
                controller: _gridController,
                padding: const EdgeInsets.only(
                  right: AppSpacing.xs,
                  bottom: AppSpacing.lg,
                ),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
                childAspectRatio: 0.95,
                children: [
                  for (final category in filteredCategories)
                    CategoryPickerTile(
                      category: category,
                      selected: category == widget.selectedCategory,
                      onTap: () => widget.onCategorySelected(category),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MintActionButton(
            label: _creating ? 'Creating...' : '+ Add Category',
            onPressed: _handleAddCategory,
          ),
        ],
      ),
    );
  }
}
