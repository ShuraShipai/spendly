import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import '../models/payment_method.dart';
import 'amount_card.dart';
import 'category_chip.dart';
import 'expense_info_field.dart';
import 'expense_note_field.dart';
import 'expense_sheet_frame.dart';
import 'expense_sheet_header.dart';
import 'mint_action_button.dart';
import 'more_chip.dart';
import 'section_label.dart';

class ExpenseDetailsStep extends StatelessWidget {
  const ExpenseDetailsStep({
    required this.amount,
    required this.category,
    required this.categories,
    required this.selectedDate,
    required this.note,
    required this.paymentMethod,
    required this.showPaymentError,
    required this.onClose,
    required this.onBack,
    required this.onCategoryChanged,
    required this.onAddCategory,
    required this.onDatePressed,
    required this.onNoteChanged,
    required this.onPaymentMethodChanged,
    required this.onSave,
    super.key,
  });

  final String amount;
  final ExpenseCategory category;
  final List<ExpenseCategory> categories;
  final DateTime selectedDate;
  final String note;
  final PaymentMethod? paymentMethod;
  final bool showPaymentError;
  final VoidCallback onClose;
  final VoidCallback onBack;
  final ValueChanged<ExpenseCategory> onCategoryChanged;
  final VoidCallback onAddCategory;
  final VoidCallback onDatePressed;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = [
      ...categories,
      if (!categories.contains(category)) category,
    ];

    return ExpenseSheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpenseSheetHeader(
            title: 'New expense',
            leadingIcon: Icons.close_rounded,
            onLeadingPressed: onClose,
          ),
          const SizedBox(height: AppSpacing.md),
          AmountCard(amount: amount),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('CATEGORY'),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final option in visibleCategories)
                ExpenseCategoryChip(
                  category: option,
                  selected: option == category,
                  onTap: () => onCategoryChanged(option),
                ),
              MoreChip(onTap: onAddCategory),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ExpenseInfoField(
                  label: 'DATE',
                  value: _formatDate(selectedDate),
                  icon: Icons.calendar_month_rounded,
                  onTap: onDatePressed,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PopupMenuButton<PaymentMethod>(
                  onSelected: onPaymentMethodChanged,
                  itemBuilder: (context) {
                    return [
                      for (final method in PaymentMethod.values)
                        PopupMenuItem(value: method, child: Text(method.label)),
                    ];
                  },
                  child: ExpenseInfoField(
                    label: 'PAY VIA',
                    value: paymentMethod?.label ?? '',
                    indicatorColor: paymentMethod == null
                        ? null
                        : AppColors.transport,
                    hasError: showPaymentError,
                    helperText: showPaymentError ? 'Required' : null,
                    showDisclosure: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ExpenseNoteField(note: note, onChanged: onNoteChanged),
          const Spacer(),
          MintActionButton(label: 'Save expense', onPressed: onSave),
        ],
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
