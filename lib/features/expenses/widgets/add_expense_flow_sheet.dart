import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/expense_category.dart';
import '../providers/add_expense_flow_controller.dart';
import '../providers/expense_provider.dart';
import '../services/custom_category_service.dart';
import 'amount_keypad_step.dart';
import 'category_picker_step.dart';
import 'expense_celebration_step.dart';
import 'expense_details_step.dart';

class AddExpenseFlowSheet extends StatefulWidget {
  const AddExpenseFlowSheet({super.key, this.userId});

  /// Optional override for tests when [AuthProvider] is not available.
  final String? userId;

  @override
  State<AddExpenseFlowSheet> createState() => _AddExpenseFlowSheetState();
}

class _AddExpenseFlowSheetState extends State<AddExpenseFlowSheet> {
  late final AddExpenseFlowController _controller;
  var _loadedCustomCategories = false;

  @override
  void initState() {
    super.initState();
    _controller = AddExpenseFlowController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedCustomCategories) {
      return;
    }
    _loadedCustomCategories = true;
    _controller.loadCustomCategories(
      userId: _userId,
      service: _categoryService,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _userId {
    if (widget.userId != null) {
      return widget.userId;
    }

    try {
      return context.read<AuthProvider>().user?.uid;
    } on ProviderNotFoundException {
      return null;
    }
  }

  CustomCategoryService? get _categoryService {
    try {
      return context.read<CustomCategoryService>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  ExpenseProvider? get _expenseProvider {
    try {
      return context.read<ExpenseProvider>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = _controller.selectedDate.isAfter(today)
        ? today
        : _controller.selectedDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (pickedDate != null) {
      _controller.setDate(pickedDate);
    }
  }

  Future<void> _saveExpense() async {
    await _controller.saveExpense(
      userId: _userId,
      categoryService: _categoryService,
      expenseProvider: _expenseProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_controller.step) {
            AddExpenseStep.amount => AmountKeypadStep(
              key: const ValueKey('amount'),
              amount: _controller.amount,
              onClose: () => Navigator.of(context).pop(),
              onKeyPressed: _controller.appendAmount,
              onPresetAmountPressed: _controller.addPresetAmount,
              onBackspace: _controller.backspaceAmount,
              onNext: () => _controller.goTo(AddExpenseStep.details),
            ),
            AddExpenseStep.details => ExpenseDetailsStep(
              key: const ValueKey('details'),
              amount: _controller.amount,
              category: _controller.category,
              categories: ExpenseCategory.quickDefaults,
              selectedDate: _controller.selectedDate,
              note: _controller.note,
              paymentMethod: _controller.paymentMethod,
              showPaymentError: _controller.showPaymentError,
              isSaving: _controller.isSavingExpense,
              onClose: () => Navigator.of(context).pop(),
              onBack: () => _controller.goTo(AddExpenseStep.amount),
              onCategoryChanged: _controller.selectCategory,
              onAddCategory: () =>
                  _controller.goTo(AddExpenseStep.categoryPicker),
              onDatePressed: _pickDate,
              onNoteChanged: _controller.setNote,
              onPaymentMethodChanged: _controller.setPaymentMethod,
              onSave: _saveExpense,
            ),
            AddExpenseStep.categoryPicker => CategoryPickerStep(
              key: const ValueKey('category-picker'),
              categories: _controller.categories,
              selectedCategory: _controller.category,
              onBack: () => _controller.goTo(AddExpenseStep.details),
              onCategorySelected: _controller.selectCategory,
              onCreateCategory: (label) {
                return _controller.createCustomCategory(
                  label: label,
                  userId: _userId,
                  service: _categoryService,
                );
              },
            ),
            AddExpenseStep.celebration => ExpenseCelebrationStep(
              key: const ValueKey('celebration'),
              expense: _controller.savedExpense!,
              onDone: () => Navigator.of(context).pop(),
              onAddAnother: _controller.resetDraft,
            ),
          },
        );
      },
    );
  }
}
