import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/expense_category.dart';
import '../models/payment_method.dart';
import '../services/custom_category_service.dart';
import 'amount_keypad_step.dart';
import 'expense_details_step.dart';

class AddExpenseFlowSheet extends StatefulWidget {
  const AddExpenseFlowSheet({super.key, this.userId});

  /// Optional override for tests when [AuthProvider] is not available.
  final String? userId;

  @override
  State<AddExpenseFlowSheet> createState() => _AddExpenseFlowSheetState();
}

class _AddExpenseFlowSheetState extends State<AddExpenseFlowSheet> {
  var _step = _ExpenseStep.amount;
  var _amount = '0';
  var _category = ExpenseCategory.food;
  var _categories = ExpenseCategory.defaults;
  var _selectedDate = DateTime.now();
  PaymentMethod? _paymentMethod;
  var _showPaymentError = false;
  var _loadedCustomCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedCustomCategories) {
      return;
    }
    _loadedCustomCategories = true;
    _loadCustomCategories();
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

  Future<void> _loadCustomCategories() async {
    final userId = _userId;
    final service = _categoryService;
    if (userId == null || service == null) {
      return;
    }

    final customCategories = await service.loadCustomCategories(userId);
    if (!mounted) {
      return;
    }

    setState(() {
      _categories = _mergeCategories(customCategories);
      if (_categories.contains(_category)) {
        return;
      }
      _category = ExpenseCategory.food;
    });
  }

  List<ExpenseCategory> _mergeCategories(
    Iterable<ExpenseCategory> customCategories,
  ) {
    final merged = [...ExpenseCategory.defaults];
    for (final category in customCategories) {
      if (!merged.any((existing) => existing.id == category.id)) {
        merged.add(category);
      }
    }
    return merged;
  }

  void _appendAmount(String value) {
    setState(() {
      if (value == '.' && _amount.contains('.')) {
        return;
      }
      if (_amount == '0' && value != '.') {
        _amount = value;
        return;
      }
      _amount += value;
    });
  }

  void _backspaceAmount() {
    setState(() {
      if (_amount.length <= 1) {
        _amount = '0';
        return;
      }
      _amount = _amount.substring(0, _amount.length - 1);
    });
  }

  Future<void> _addCustomCategory() async {
    final category = await showDialog<ExpenseCategory>(
      context: context,
      builder: (context) => const _CustomCategoryDialog(),
    );

    if (category == null) {
      return;
    }

    final existingIndex = _categories.indexWhere(
      (existing) => existing.id == category.id,
    );

    setState(() {
      if (existingIndex >= 0) {
        _category = _categories[existingIndex];
        return;
      }
      _categories = [..._categories, category];
      _category = category;
    });
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = _selectedDate.isAfter(today) ? today : _selectedDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _saveExpense() async {
    if (_paymentMethod == null) {
      setState(() => _showPaymentError = true);
      return;
    }

    final userId = _userId;
    final service = _categoryService;
    if (userId != null && service != null && _category.isCustom) {
      await service.saveCustomCategory(userId, _category);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ₹$_amount ${_category.label} expense')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAmountStep = _step == _ExpenseStep.amount;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: isAmountStep
          ? AmountKeypadStep(
              key: const ValueKey('amount'),
              amount: _amount,
              onClose: () => Navigator.of(context).pop(),
              onKeyPressed: _appendAmount,
              onBackspace: _backspaceAmount,
              onNext: () => setState(() => _step = _ExpenseStep.details),
            )
          : ExpenseDetailsStep(
              key: const ValueKey('details'),
              amount: _amount,
              category: _category,
              categories: _categories,
              selectedDate: _selectedDate,
              paymentMethod: _paymentMethod,
              showPaymentError: _showPaymentError,
              onClose: () => Navigator.of(context).pop(),
              onBack: () => setState(() => _step = _ExpenseStep.amount),
              onCategoryChanged: (category) {
                setState(() => _category = category);
              },
              onAddCategory: _addCustomCategory,
              onDatePressed: _pickDate,
              onPaymentMethodChanged: (method) {
                setState(() {
                  _paymentMethod = method;
                  _showPaymentError = false;
                });
              },
              onSave: _saveExpense,
            ),
    );
  }
}

enum _ExpenseStep { amount, details }

class _CustomCategoryDialog extends StatefulWidget {
  const _CustomCategoryDialog();

  @override
  State<_CustomCategoryDialog> createState() => _CustomCategoryDialogState();
}

class _CustomCategoryDialogState extends State<_CustomCategoryDialog> {
  final _controller = TextEditingController();
  var _showError = false;

  static const _customColors = [
    AppColors.rent,
    AppColors.health,
    AppColors.entertainment,
    AppColors.travel,
    AppColors.bills,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final label = _controller.text.trim();
    if (label.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    final color = _customColors[label.length % _customColors.length];
    Navigator.of(
      context,
    ).pop(ExpenseCategory.custom(label: label, color: color));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_showError) {
            setState(() => _showError = false);
          }
        },
        decoration: InputDecoration(
          hintText: 'Category name',
          errorText: _showError ? 'Enter a category name' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
