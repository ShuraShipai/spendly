import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
          onUndo: () {
            onUndo();
            dismiss();
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 2800), dismiss);
}

class ExpenseDeletedSnackBar extends StatelessWidget {
  const ExpenseDeletedSnackBar({required this.onUndo, super.key});

  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        child: Row(
          children: [
            const Icon(
              Icons.check_rounded,
              color: AppColors.groceries,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Expense deleted',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
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
                    color: const Color(0xFF5FE0C0),
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
