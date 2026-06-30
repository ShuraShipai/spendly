import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import 'amount_shortcut.dart';
import 'expense_sheet_frame.dart';
import 'expense_sheet_header.dart';
import 'mint_action_button.dart';
import 'number_pad.dart';

class AmountKeypadStep extends StatelessWidget {
  const AmountKeypadStep({
    required this.amount,
    required this.category,
    required this.onClose,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onNext,
    super.key,
  });

  final String amount;
  final ExpenseCategory category;
  final VoidCallback onClose;
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ExpenseSheetFrame(
      child: Column(
        children: [
          ExpenseSheetHeader(
            title: 'How much?',
            leadingIcon: Icons.chevron_left_rounded,
            onLeadingPressed: onClose,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.label.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle),
                ),
                const SizedBox(height: AppSpacing.xs),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displaySmall,
                    children: [
                      TextSpan(
                        text: '₹',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.inkMuted),
                      ),
                      TextSpan(text: amount),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AmountShortcut(
                      label: '+₹50',
                      onTap: () => onKeyPressed('50'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AmountShortcut(
                      label: '+₹100',
                      onTap: () => onKeyPressed('100'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AmountShortcut(
                      label: '+₹500',
                      onTap: () => onKeyPressed('500'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          NumberPad(onKeyPressed: onKeyPressed, onBackspace: onBackspace),
          const SizedBox(height: AppSpacing.sm),
          MintActionButton(label: 'Next', onPressed: onNext),
        ],
      ),
    );
  }
}
