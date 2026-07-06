import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'expense_deleted_progress_indicator.dart';

const expenseDeletedSnackBarDuration = Duration(seconds: 5);

void showExpenseDeletedSnackBar({
  required BuildContext context,
  required VoidCallback onUndo,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  var isDismissed = false;
  late final OverlayEntry entry;

  void dismiss() {
    if (isDismissed) {
      return;
    }

    isDismissed = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 18,
      right: 18,
      bottom: 84,
      child: Material(
        color: Colors.transparent,
        child: ExpenseDeletedSnackBar(
          duration: expenseDeletedSnackBarDuration,
          onUndo: () {
            onUndo();
            dismiss();
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(expenseDeletedSnackBarDuration, dismiss);
}

class ExpenseDeletedSnackBar extends StatelessWidget {
  const ExpenseDeletedSnackBar({
    required this.duration,
    required this.onUndo,
    super.key,
  });

  final Duration duration;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.25),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        child: Row(
          children: [
            ExpenseDeletedProgressIndicator(duration: duration),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Expense deleted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onInverseSurface,
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            InkWell(
              onTap: onUndo,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: Text(
                  'UNDO',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mint,
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
