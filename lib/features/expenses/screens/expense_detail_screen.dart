import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';
import '../providers/expense_provider.dart';
import '../widgets/delete_expense_confirmation_sheet.dart';
import '../widgets/expense_delete_button.dart';
import '../widgets/expense_deleted_snack_bar.dart';
import '../widgets/expense_detail_header.dart';
import '../widgets/expense_hero_amount.dart';
import '../widgets/expense_info_card.dart';
import '../widgets/mint_action_button.dart';
import 'edit_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({required this.expenseId, super.key});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseProvider>().expenseById(expenseId);
    if (expense == null) {
      return const Scaffold(body: Center(child: Text('Expense not found')));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              ExpenseDetailHeader(onBack: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.xl),
              ExpenseHeroAmount(expense: expense),
              const SizedBox(height: AppSpacing.xl),
              ExpenseInfoCard(expense: expense),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: MintActionButton(
                      label: 'Edit',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                EditExpenseScreen(expenseId: expense.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ExpenseDeleteButton(
                    onTap: () => _confirmAndDeleteExpense(context, expense),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteExpense(
    BuildContext context,
    ExpenseEntry expense,
  ) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => DeleteExpenseConfirmationSheet(expense: expense),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    final expenseProvider = context.read<ExpenseProvider>();
    final navigator = Navigator.of(context);
    final deletedExpense = expenseProvider.deleteExpense(expense.id);
    if (deletedExpense == null) {
      return;
    }

    showExpenseDeletedSnackBar(
      context: context,
      onUndo: () {
        expenseProvider.restoreExpense(deletedExpense);
      },
    );
    navigator.pop();
  }
}
