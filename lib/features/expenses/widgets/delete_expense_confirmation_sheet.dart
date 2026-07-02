import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/expense_entry.dart';

class DeleteExpenseConfirmationSheet extends StatelessWidget {
  const DeleteExpenseConfirmationSheet({required this.expense, super.key});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
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
            const _DeleteIcon(),
            const SizedBox(height: 14),
            Text(
              'Delete this expense?',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 19,
                height: 1.2,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
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
                color: AppColors.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SheetActionButton(
                    label: 'Keep',
                    foregroundColor: AppColors.inkMuted,
                    backgroundColor: const Color(0xFFF2EEE8),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetActionButton(
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

class _DeleteIcon extends StatelessWidget {
  const _DeleteIcon();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const SizedBox.square(
        dimension: 60,
        child: Icon(
          Icons.delete_outline_rounded,
          color: AppColors.danger,
          size: 28,
        ),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
    this.boxShadow,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: boxShadow,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
