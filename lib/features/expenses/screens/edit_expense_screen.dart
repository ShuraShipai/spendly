import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import '../models/payment_method.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/expense_info_field.dart';
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
  late ExpenseCategory _category;
  late DateTime _date;
  late PaymentMethod _paymentMethod;
  var _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    final expense = context.read<ExpenseProvider>().expenseById(
      widget.expenseId,
    );
    if (expense == null) {
      _amountController = TextEditingController(text: '0');
      _noteController = TextEditingController();
      _category = ExpenseCategory.food;
      _date = DateTime.now();
      _paymentMethod = PaymentMethod.cash;
      return;
    }

    _amountController = TextEditingController(
      text: expense.amount == expense.amount.roundToDouble()
          ? expense.amount.round().toString()
          : expense.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: expense.note ?? '');
    _category = expense.category;
    _date = expense.date;
    _paymentMethod = expense.paymentMethod;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>().expenseById(
      widget.expenseId,
    );
    if (expense == null) {
      return const Scaffold(body: Center(child: Text('Expense not found')));
    }

    final categories = [
      ...ExpenseCategory.defaults,
      if (!ExpenseCategory.defaults.contains(_category)) _category,
    ];

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
            _Header(
              onCancel: () => Navigator.of(context).pop(),
              onSave: () => _save(expense.id),
            ),
            const SizedBox(height: AppSpacing.lg),
            _AmountEditor(controller: _amountController),
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
              label: 'Save changes',
              onPressed: () => _save(expense.id),
            ),
          ],
        ),
      ),
    );
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

  void _save(String expenseId) {
    final expense = context.read<ExpenseProvider>().expenseById(expenseId);
    if (expense == null) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final note = _noteController.text.trim();
    context.read<ExpenseProvider>().updateExpense(
      expense.copyWith(
        amount: amount,
        category: _category,
        date: _date,
        paymentMethod: _paymentMethod,
        note: note.isEmpty ? null : note,
      ),
    );
    Navigator.of(context).pop();
  }

  InputDecoration _fieldDecoration(BuildContext context, String hintText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodySmall,
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
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

class _Header extends StatelessWidget {
  const _Header({required this.onCancel, required this.onSave});

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        Expanded(
          child: Text(
            'Edit expense',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(onPressed: onSave, child: const Text('Save')),
      ],
    );
  }
}

class _AmountEditor extends StatelessWidget {
  const _AmountEditor({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mint, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3334C6A8),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'AMOUNT',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle),
            ),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
              decoration: const InputDecoration(prefixText: '₹'),
            ),
          ],
        ),
      ),
    );
  }
}
