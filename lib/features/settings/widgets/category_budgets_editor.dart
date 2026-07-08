import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../expenses/models/expense_category.dart';
import '../models/budget_editor_request.dart';
import '../providers/settings_provider.dart';
import 'budget_amount_sheet.dart';
import 'monthly_budget_actions_sheet.dart';

typedef CategoryBudgetsChildBuilder =
    Widget Function(BuildContext context, CategoryBudgetsEditorActions actions);

class CategoryBudgetsEditorActions {
  const CategoryBudgetsEditorActions({
    required this.editMonthlyBudget,
    required this.resetCategoryBudgets,
    required this.editCategory,
  });

  final void Function(double currentBudget) editMonthlyBudget;
  final VoidCallback resetCategoryBudgets;
  final void Function(ExpenseCategory category) editCategory;
}

class CategoryBudgetsEditor extends StatefulWidget {
  const CategoryBudgetsEditor({
    required this.initialEditorRequest,
    required this.childBuilder,
    super.key,
  });

  final BudgetEditorRequest? initialEditorRequest;
  final CategoryBudgetsChildBuilder childBuilder;

  @override
  State<CategoryBudgetsEditor> createState() => _CategoryBudgetsEditorState();
}

class _CategoryBudgetsEditorState extends State<CategoryBudgetsEditor> {
  BudgetEditorRequest? _pendingEditorRequest;
  var _isOpeningRequestedEditor = false;

  @override
  void initState() {
    super.initState();
    _pendingEditorRequest = widget.initialEditorRequest;
  }

  @override
  void didUpdateWidget(covariant CategoryBudgetsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialEditorRequest != oldWidget.initialEditorRequest) {
      _pendingEditorRequest = widget.initialEditorRequest;
      _isOpeningRequestedEditor = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    _scheduleRequestedEditor(settingsProvider);

    return widget.childBuilder(
      context,
      CategoryBudgetsEditorActions(
        editMonthlyBudget: _showMonthlyBudgetActions,
        resetCategoryBudgets: _resetCategoryBudgets,
        editCategory: _openCategoryBudgetEditor,
      ),
    );
  }

  void _resetCategoryBudgets() {
    context.read<SettingsProvider>().resetCategoryBudgets();
  }

  void _scheduleRequestedEditor(SettingsProvider settingsProvider) {
    final request = _pendingEditorRequest;
    if (request == null || _isOpeningRequestedEditor) {
      return;
    }

    if (settingsProvider.isLoadingBudget) {
      return;
    }

    final categoryId = request.categoryId;
    if (categoryId != null &&
        !settingsProvider.categories.any(
          (category) => category.id == categoryId,
        )) {
      return;
    }

    _isOpeningRequestedEditor = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final request = _pendingEditorRequest;
      if (request == null) {
        _isOpeningRequestedEditor = false;
        return;
      }

      _pendingEditorRequest = null;
      _isOpeningRequestedEditor = false;
      _openRequestedEditor(request);
    });
  }

  void _openRequestedEditor(BudgetEditorRequest request) {
    final settingsProvider = context.read<SettingsProvider>();
    final categoryId = request.categoryId;

    if (categoryId == null) {
      _showBudgetSheet(
        title: 'Monthly budget',
        initialAmount: settingsProvider.monthlyBudget,
        onSave: settingsProvider.setMonthlyBudget,
      );
      return;
    }

    ExpenseCategory? category;
    for (final candidate in settingsProvider.categories) {
      if (candidate.id == categoryId) {
        category = candidate;
        break;
      }
    }

    if (category == null) {
      return;
    }

    final selectedCategory = category;

    _showBudgetSheet(
      title: '${selectedCategory.label} budget',
      initialAmount: settingsProvider.budgetForCategory(selectedCategory.id),
      onSave: (amount) => context.read<SettingsProvider>().setCategoryBudget(
        selectedCategory.id,
        amount,
      ),
    );
  }

  void _openCategoryBudgetEditor(ExpenseCategory category) {
    final settingsProvider = context.read<SettingsProvider>();
    _showBudgetSheet(
      title: '${category.label} budget',
      initialAmount: settingsProvider.budgetForCategory(category.id),
      onSave: (amount) => context.read<SettingsProvider>().setCategoryBudget(
        category.id,
        amount,
      ),
    );
  }

  void _showMonthlyBudgetActions(double currentBudget) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MonthlyBudgetActionsSheet(
        currentBudget: currentBudget,
        onEditLimit: () {
          Navigator.of(context).pop();
          _showBudgetSheet(
            title: 'Monthly budget',
            initialAmount: currentBudget,
            onSave: context.read<SettingsProvider>().setMonthlyBudget,
          );
        },
        onResetLimit: () {
          Navigator.of(context).pop();
          context.read<SettingsProvider>().setMonthlyBudget(0);
        },
      ),
    );
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
}
