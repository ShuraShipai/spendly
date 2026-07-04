import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_category.dart';
import '../models/expense_entry.dart';
import '../models/payment_method.dart';
import '../services/custom_category_service.dart';
import 'expense_provider.dart';

enum AddExpenseStep { details, amount, categoryPicker, celebration }

class AddExpenseFlowController extends ChangeNotifier {
  var step = AddExpenseStep.details;
  var amount = '0';
  var category = ExpenseCategory.food;
  var categories = ExpenseCategory.defaults;
  var selectedDate = DateTime.now();
  var note = '';
  PaymentMethod? paymentMethod;
  ExpenseEntry? savedExpense;
  var showPaymentError = false;
  var isSavingExpense = false;

  Future<void> loadCustomCategories({
    required String? userId,
    required CustomCategoryService? service,
  }) async {
    if (userId == null || service == null) {
      return;
    }

    final customCategories = await service.loadCustomCategories(userId);
    if (customCategories.isEmpty) {
      return;
    }

    categories = [
      ...ExpenseCategory.defaults,
      for (final category in customCategories)
        if (!ExpenseCategory.defaults.any(
          (defaultCategory) =>
              defaultCategory.id == category.id ||
              defaultCategory.hasSameLabel(category.label),
        ))
          category,
    ];
    notifyListeners();
  }

  void appendAmount(String value) {
    final nextAmount = _appendAmountInput(amount, value);
    if (nextAmount == amount) {
      return;
    }
    amount = nextAmount;
    notifyListeners();
  }

  void addPresetAmount(int value) {
    final nextAmountCents = _parseAmountCents(amount) + (value * 100);
    amount = _formatCents(nextAmountCents);
    notifyListeners();
  }

  void backspaceAmount() {
    amount = _backspaceAmountInput(amount);
    notifyListeners();
  }

  void goTo(AddExpenseStep nextStep) {
    step = nextStep;
    notifyListeners();
  }

  void selectCategory(ExpenseCategory selectedCategory) {
    category = selectedCategory;
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

    categories = [...categories, customCategory];
    if (userId != null && service != null) {
      await service.saveCustomCategory(userId, customCategory);
    }
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

    final parsedAmount = double.tryParse(amount) ?? 0;
    if (parsedAmount <= 0) {
      step = AddExpenseStep.amount;
      notifyListeners();
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
      final expense = ExpenseEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        amount: parsedAmount,
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
    step = AddExpenseStep.details;
    amount = '0';
    category = ExpenseCategory.food;
    selectedDate = DateTime.now();
    note = '';
    paymentMethod = null;
    savedExpense = null;
    showPaymentError = false;
    isSavingExpense = false;
    notifyListeners();
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

  String _appendAmountInput(String currentAmount, String value) {
    if (value == '.') {
      if (currentAmount.contains('.')) {
        return currentAmount;
      }
      return '$currentAmount.';
    }

    final decimalIndex = currentAmount.indexOf('.');
    if (decimalIndex >= 0) {
      final decimalPlaces = currentAmount.length - decimalIndex - 1;
      if (decimalPlaces >= 2) {
        return currentAmount;
      }
      return '$currentAmount$value';
    }

    if (currentAmount == '0') {
      return value;
    }

    return '$currentAmount$value';
  }

  String _backspaceAmountInput(String currentAmount) {
    if (currentAmount.length <= 1) {
      return '0';
    }

    final nextAmount = currentAmount.substring(0, currentAmount.length - 1);
    if (nextAmount.isEmpty || nextAmount == '0.') {
      return '0';
    }

    return nextAmount;
  }

  int _parseAmountCents(String value) {
    final parts = value.split('.');
    final wholePart =
        int.tryParse(parts.first.isEmpty ? '0' : parts.first) ?? 0;
    if (parts.length == 1) {
      return wholePart * 100;
    }

    final decimalText = parts[1].padRight(2, '0').substring(0, 2);
    final centsPart = int.tryParse(decimalText) ?? 0;
    return (wholePart * 100) + centsPart;
  }

  String _formatCents(int cents) {
    final whole = cents ~/ 100;
    final remainder = cents % 100;
    if (remainder == 0) {
      return whole.toString();
    }

    final decimalText = remainder.toString().padLeft(2, '0');
    return '$whole.${decimalText.endsWith('0') ? decimalText[0] : decimalText}';
  }
}
