import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import '../models/expense_entry.dart';
import '../models/payment_method.dart';
import '../providers/expense_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/edit_amount_editor.dart';
import '../widgets/edit_expense_header.dart';
import '../widgets/expense_info_field.dart';
import '../widgets/expense_theme.dart';
import '../widgets/mint_action_button.dart';
import '../widgets/section_label.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({required this.expenseId, super.key});

  final String expenseId;

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  var _category = ExpenseCategory.food;
  var _date = DateTime.now();
  var _paymentMethod = PaymentMethod.cash;
  var _loaded = false;
  var _isSaving = false;
  String? _amountError;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  void _loadExpense(ExpenseEntry expense) {
    _amountController.text = expense.amount == expense.amount.roundToDouble()
        ? expense.amount.round().toString()
        : expense.amount.toStringAsFixed(2);
    _noteController.text = expense.note ?? '';
    _category = expense.category;
    _date = expense.date;
    _paymentMethod = expense.paymentMethod;
    _loaded = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final expense = expenseProvider.expenseById(widget.expenseId);
    if (expense == null) {
      return Scaffold(
        body: Center(
          child: expenseProvider.isLoading
              ? const CircularProgressIndicator()
              : const Text('Expense not found'),
        ),
      );
    }

    if (!_loaded) {
      _loadExpense(expense);
    }

    final settingsProvider = _watchSettingsProvider(context);
    final categories = _mergeCategories(
      expenseProvider.availableCategories(),
      settingsProvider?.categories ?? const [],
    );
    if (!categories.contains(_category)) {
      categories.add(_category);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            EditExpenseHeader(
              onCancel: () => Navigator.of(context).pop(),
              onSave: _isSaving ? () {} : () => _save(expense.id),
            ),
            const SizedBox(height: AppSpacing.lg),
            EditAmountEditor(
              controller: _amountController,
              errorText: _amountError,
              onChanged: (_) {
                if (_amountError != null) {
                  setState(() => _amountError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('CATEGORY'),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final category in categories)
                  ExpenseCategoryChip(
                    category: category,
                    selected: category == _category,
                    onTap: () => setState(() => _category = category),
                  ),
              ],
            ),
            if (_saveError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _saveError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('NOTE'),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _noteController,
              minLines: 1,
              maxLines: 2,
              decoration: _fieldDecoration(context, 'Add a note'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ExpenseInfoField(
                    label: 'DATE',
                    value: _formatDate(_date),
                    icon: Icons.calendar_month_rounded,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PopupMenuButton<PaymentMethod>(
                    onSelected: (method) {
                      setState(() => _paymentMethod = method);
                    },
                    itemBuilder: (context) {
                      return [
                        for (final method in PaymentMethod.values)
                          PopupMenuItem(
                            value: method,
                            child: Text(method.label),
                          ),
                      ];
                    },
                    child: ExpenseInfoField(
                      label: 'PAY VIA',
                      value: _paymentMethod.label,
                      indicatorColor: AppColors.transport,
                      showDisclosure: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            MintActionButton(
              label: _isSaving ? 'Saving...' : 'Save changes',
              isEnabled: !_isSaving,
              onPressed: () => _save(expense.id),
            ),
          ],
        ),
      ),
    );
  }

  SettingsProvider? _watchSettingsProvider(BuildContext context) {
    try {
      return context.watch<SettingsProvider>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  List<ExpenseCategory> _mergeCategories(
    List<ExpenseCategory> primary,
    List<ExpenseCategory> secondary,
  ) {
    final categories = [...primary];
    for (final category in secondary) {
      final alreadyIncluded = categories.any(
        (existing) =>
            existing.id == category.id || existing.hasSameLabel(category.label),
      );
      if (!alreadyIncluded) {
        categories.add(category);
      }
    }
    return categories;
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (pickedDate != null) {
      setState(() => _date = pickedDate);
    }
  }

  Future<void> _save(String expenseId) async {
    if (_isSaving) {
      return;
    }

    final expenseProvider = context.read<ExpenseProvider>();
    final navigator = Navigator.of(context);
    final expense = expenseProvider.expenseById(expenseId);
    if (expense == null) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Enter an amount greater than ₹0';
        _saveError = null;
      });
      return;
    }

    final note = _noteController.text.trim();
    final updatedExpense = expense.copyWith(
      amount: amount,
      category: _category,
      date: _date,
      paymentMethod: _paymentMethod,
      note: note.isEmpty ? null : note,
    );

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final saved = await expenseProvider.updateExpense(updatedExpense);
    if (!mounted) {
      return;
    }

    if (saved) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _isSaving = false;
      _saveError = expenseProvider.errorMessage ?? 'Could not update expense.';
    });
  }

  InputDecoration _fieldDecoration(BuildContext context, String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodySmall,
      filled: true,
      fillColor: ExpenseTheme.surface(context),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: ExpenseTheme.outline(context),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
