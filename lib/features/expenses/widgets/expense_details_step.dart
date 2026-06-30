import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
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
    required this.onClose,
    required this.onBack,
    required this.onCategoryChanged,
    required this.onSave,
    super.key,
  });

  final String amount;
  final ExpenseCategory category;
  final VoidCallback onClose;
  final VoidCallback onBack;
  final ValueChanged<ExpenseCategory> onCategoryChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
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
              for (final option in ExpenseCategory.values)
                ExpenseCategoryChip(
                  category: option,
                  selected: option == category,
                  onTap: () => onCategoryChanged(option),
                ),
              MoreChip(onTap: onBack),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: ExpenseInfoField(
                  label: 'DATE',
                  value: 'Today',
                  icon: Icons.calendar_month_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ExpenseInfoField(
                  label: 'PAY VIA',
                  value: 'UPI',
                  indicatorColor: AppColors.transport,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const ExpenseNoteField(),
          const Spacer(),
          MintActionButton(label: 'Save expense', onPressed: onSave),
        ],
      ),
    );
  }
}
