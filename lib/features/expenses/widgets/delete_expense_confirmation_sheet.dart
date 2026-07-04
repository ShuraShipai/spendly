import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_entry.dart';
import 'delete_expense_icon.dart';
import 'delete_expense_sheet_action_button.dart';

class DeleteExpenseConfirmationSheet extends StatelessWidget {
  const DeleteExpenseConfirmationSheet({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final sheetColor = isDark ? AppColors.darkSurface : AppColors.card;
    final keepColor = isDark
        ? AppColors.darkBackground
        : const Color(0xFFF2EEE8);
    final titleColor = isDark ? AppColors.darkInk : AppColors.ink;
    final descriptionColor = isDark
        ? AppColors.darkInkMuted
        : AppColors.inkMuted;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 30,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DeleteExpenseIcon(),
            const SizedBox(height: 14),
            Text(
              'Delete this expense?',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 19,
                height: 1.2,
                fontWeight: FontWeight.w900,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              '"${expense.displayTitle}" · ${expense.amountLabel}.\nYou can undo this for a few seconds.',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: descriptionColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: DeleteExpenseSheetActionButton(
                    label: 'Keep',
                    foregroundColor: descriptionColor,
                    backgroundColor: keepColor,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DeleteExpenseSheetActionButton(
                    label: 'Delete',
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.danger,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66E66A55),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
