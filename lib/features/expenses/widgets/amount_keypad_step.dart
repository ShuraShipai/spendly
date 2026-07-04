import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'amount_shortcut.dart';
import 'expense_sheet_frame.dart';
import 'expense_sheet_header.dart';
import 'mint_action_button.dart';
import 'number_pad.dart';

class AmountKeypadStep extends StatelessWidget {
  const AmountKeypadStep({
    required this.amount,
    required this.categoryLabel,
    required this.onClose,
    required this.onKeyPressed,
    required this.onPresetAmountPressed,
    required this.onBackspace,
    required this.onNext,
    super.key,
  });

  final String amount;
  final String categoryLabel;
  final VoidCallback onClose;
  final ValueChanged<String> onKeyPressed;
  final ValueChanged<int> onPresetAmountPressed;
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
                  categoryLabel.toUpperCase(),
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
                      onTap: () => onPresetAmountPressed(50),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AmountShortcut(
                      label: '+₹100',
                      onTap: () => onPresetAmountPressed(100),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AmountShortcut(
                      label: '+₹500',
                      onTap: () => onPresetAmountPressed(500),
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
