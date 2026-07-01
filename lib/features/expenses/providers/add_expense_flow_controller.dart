import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_category.dart';
import '../models/expense_entry.dart';
import '../models/payment_method.dart';
import '../services/custom_category_service.dart';
import 'expense_provider.dart';

enum AddExpenseStep { amount, details, categoryPicker, celebration }

class AddExpenseFlowController extends ChangeNotifier {
  var step = AddExpenseStep.amount;
  var amount = '0';
  var category = ExpenseCategory.food;
  var categories = ExpenseCategory.defaults;
  var selectedDate = DateTime.now();
  var note = '';
  PaymentMethod? paymentMethod;
  ExpenseEntry? savedExpense;
  var showPaymentError = false;
  var isSavingExpense = false;
  double? _presetKeypadBaseAmount;
  var _presetKeypadEntry = '';

  Future<void> loadCustomCategories({
    required String? userId,
    required CustomCategoryService? service,
  }) async {
    if (userId == null || service == null) {
      return;
    }

    final customCategories = await service.loadCustomCategories(userId);
    categories = _mergeCategories(customCategories);
    if (!categories.contains(category)) {
      category = ExpenseCategory.food;
    }
    notifyListeners();
  }

  void appendAmount(String value) {
    if (_presetKeypadBaseAmount != null) {
      _appendPresetKeypadEntry(value);
      return;
    }

    if (value == '.' && amount.contains('.')) {
      return;
    }
    if (amount == '0' && value != '.') {
      amount = value;
    } else {
      amount += value;
    }
    notifyListeners();
  }

  void addPresetAmount(int value) {
    final currentAmount = double.tryParse(amount) ?? 0;
    final nextAmount = currentAmount + value;
    _presetKeypadBaseAmount = nextAmount;
    _presetKeypadEntry = '';
    amount = _formatAmount(nextAmount);
    notifyListeners();
  }

  void backspaceAmount() {
    if (_presetKeypadBaseAmount != null && _presetKeypadEntry.isNotEmpty) {
      _presetKeypadEntry = _presetKeypadEntry.substring(
        0,
        _presetKeypadEntry.length - 1,
      );
      _syncPresetAmount();
      notifyListeners();
      return;
    }

    _clearPresetKeypadEntry();
    if (amount.length <= 1) {
      amount = '0';
    } else {
      amount = amount.substring(0, amount.length - 1);
    }
    notifyListeners();
  }

  void goTo(AddExpenseStep nextStep) {
    step = nextStep;
    notifyListeners();
  }

  void selectCategory(ExpenseCategory selectedCategory) {
    category = selectedCategory;
    step = AddExpenseStep.details;
    notifyListeners();
  }

  Future<ExpenseCategory> createCustomCategory({
    required String label,
    required String? userId,
    required CustomCategoryService? service,
  }) async {
    final customCategory = ExpenseCategory.custom(
      label: label,
      color: _colorForLabel(label),
    );
    final existingIndex = categories.indexWhere(
      (existing) =>
          existing.id == customCategory.id || existing.hasSameLabel(label),
    );

    if (existingIndex >= 0) {
      return categories[existingIndex];
    }

    if (userId != null && service != null) {
      await service.saveCustomCategory(userId, customCategory);
    }

    categories = [...categories, customCategory];
    notifyListeners();
    return customCategory;
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setNote(String value) {
    note = value;
  }

  void setPaymentMethod(PaymentMethod method) {
    paymentMethod = method;
    showPaymentError = false;
    notifyListeners();
  }

  Future<bool> saveExpense({
    required String? userId,
    required CustomCategoryService? categoryService,
    required ExpenseProvider? expenseProvider,
  }) async {
    if (isSavingExpense || step != AddExpenseStep.details) {
      return false;
    }

    if (paymentMethod == null) {
      showPaymentError = true;
      notifyListeners();
      return false;
    }

    isSavingExpense = true;
    notifyListeners();

    try {
      if (userId != null && categoryService != null && category.isCustom) {
        await categoryService.saveCustomCategory(userId, category);
      }

      final expense = ExpenseEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amount: double.tryParse(amount) ?? 0,
        category: category,
        date: selectedDate,
        paymentMethod: paymentMethod!,
        note: note.trim().isEmpty ? null : note.trim(),
      );

      expenseProvider?.addExpense(expense);
      savedExpense = expense;
      step = AddExpenseStep.celebration;
      return true;
    } finally {
      isSavingExpense = false;
      notifyListeners();
    }
  }

  void resetDraft() {
    step = AddExpenseStep.amount;
    amount = '0';
    category = ExpenseCategory.food;
    selectedDate = DateTime.now();
    note = '';
    paymentMethod = null;
    savedExpense = null;
    showPaymentError = false;
    isSavingExpense = false;
    _clearPresetKeypadEntry();
    notifyListeners();
  }

  List<ExpenseCategory> _mergeCategories(
    Iterable<ExpenseCategory> customCategories,
  ) {
    final merged = [...ExpenseCategory.defaults];
    for (final customCategory in customCategories) {
      if (!merged.any((existing) => existing.id == customCategory.id)) {
        merged.add(customCategory);
      }
    }
    return merged;
  }

  Color _colorForLabel(String label) {
    const customColors = [
      AppColors.rent,
      AppColors.health,
      AppColors.entertainment,
      AppColors.travel,
      AppColors.bills,
    ];

    return customColors[label.trim().length % customColors.length];
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(2);
  }

  void _appendPresetKeypadEntry(String value) {
    if (value == '.' && _presetKeypadEntry.contains('.')) {
      return;
    }

    if (value == '.' && _presetKeypadEntry.isEmpty) {
      _presetKeypadEntry = '0.';
    } else {
      _presetKeypadEntry += value;
    }

    _syncPresetAmount();
    notifyListeners();
  }

  void _syncPresetAmount() {
    final baseAmount = _presetKeypadBaseAmount ?? 0;
    final entryAmount = double.tryParse(_presetKeypadEntry) ?? 0;
    amount = _formatAmount(baseAmount + entryAmount);
  }

  void _clearPresetKeypadEntry() {
    _presetKeypadBaseAmount = null;
    _presetKeypadEntry = '';
  }
}
