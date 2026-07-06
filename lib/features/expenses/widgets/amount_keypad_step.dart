import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'amount_shortcut.dart';
import 'expense_theme.dart';
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 430;
                final summaryGap = isCompact ? AppSpacing.xxs : AppSpacing.xs;
                final keypadGap = isCompact ? AppSpacing.xs : AppSpacing.sm;

                return Column(
                  children: [
                    Flexible(
                      flex: isCompact ? 2 : 3,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                categoryLabel.toUpperCase(),
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: ExpenseTheme.subtle(context),
                                    ),
                              ),
                              SizedBox(height: summaryGap),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                  children: [
                                    TextSpan(
                                      text: '₹',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: ExpenseTheme.muted(context),
                                          ),
                                    ),
                                    TextSpan(text: amount),
                                  ],
                                ),
                              ),
                              SizedBox(height: keypadGap),
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
                      ),
                    ),
                    SizedBox(height: keypadGap),
                    Flexible(
                      flex: isCompact ? 5 : 4,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: NumberPad(
                              onKeyPressed: onKeyPressed,
                              onBackspace: onBackspace,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: keypadGap),
                    MintActionButton(label: 'Next', onPressed: onNext),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
