import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import 'category_add_tile.dart';
import 'category_picker_tile.dart';
import 'expense_theme.dart';
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
  var _query = '';
  late var _selectedCategory = widget.selectedCategory;
  String? _errorText;

  @override
  void dispose() {
    _searchController.dispose();
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

  bool get _canAddSearchCategory {
    final normalizedQuery = _query.trim();
    if (normalizedQuery.isEmpty) {
      return false;
    }

    return _matchingCategoryFor(normalizedQuery) == null;
  }

  Future<void> _createSearchCategory() async {
    final label = _query.trim();
    if (label.isEmpty) {
      return;
    }

    try {
      final category = await widget.onCreateCategory(label);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedCategory = category;
        _errorText = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _errorText = 'Could not save category. Please try again.');
    }
  }

  ExpenseCategory? _matchingCategoryFor(String label) {
    for (final category in widget.categories) {
      if (category.hasSameLabel(label)) {
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
            onChanged: (value) => setState(() {
              _query = value;
              _errorText = null;
            }),
            decoration: InputDecoration(
              hintText: 'Search categories',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: ExpenseTheme.subtle(context),
              ),
              filled: true,
              fillColor: ExpenseTheme.surface(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: ExpenseTheme.outline(context),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
              ),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 8,
                childAspectRatio: 0.86,
              ),
              itemCount:
                  filteredCategories.length + (_canAddSearchCategory ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredCategories.length) {
                  return CategoryAddTile(
                    label: '+ ${_query.trim()}',
                    onTap: _createSearchCategory,
                  );
                }

                final category = filteredCategories[index];
                return CategoryPickerTile(
                  category: category,
                  selected: category == _selectedCategory,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MintActionButton(
            label: 'Confirm',
            onPressed: () => widget.onCategorySelected(_selectedCategory),
          ),
        ],
      ),
    );
  }
}
