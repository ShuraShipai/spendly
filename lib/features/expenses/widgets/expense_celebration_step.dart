import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';
import 'celebration_confetti_row.dart';
import 'expense_theme.dart';
import 'expense_sheet_frame.dart';
import 'mint_action_button.dart';
import 'saved_expense_card.dart';

class ExpenseCelebrationStep extends StatelessWidget {
  const ExpenseCelebrationStep({
    required this.expense,
    required this.onDone,
    required this.onAddAnother,
    super.key,
  });

  final ExpenseEntry expense;
  final VoidCallback onDone;
  final VoidCallback onAddAnother;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExpenseSheetFrame(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ExpenseTheme.mintContainer(context),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        const CelebrationConfettiRow(),
                        const Spacer(),
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AppColors.coin,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(
                            dimension: 118,
                            child: Center(
                              child: Text(
                                '₹',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(color: AppColors.coinInk),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Nice one!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your expense is saved.\nYour dashboard is live.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SavedExpenseCard(expense: expense),
                        const Spacer(),
                        MintActionButton(label: 'Done', onPressed: onDone),
                        TextButton(
                          onPressed: onAddAnother,
                          child: Text(
                            'Add another',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
