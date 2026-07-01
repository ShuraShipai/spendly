import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';
import '../providers/expense_provider.dart';
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
              _Header(
                onBack: () => Navigator.of(context).pop(),
                onDelete: () => _deleteExpense(context, expense),
              ),
              const SizedBox(height: AppSpacing.xl),
              _HeroAmount(expense: expense),
              const SizedBox(height: AppSpacing.xl),
              _ExpenseInfoCard(expense: expense),
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
                  _DeleteButton(onTap: () => _deleteExpense(context, expense)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, ExpenseEntry expense) {
    context.read<ExpenseProvider>().deleteExpense(expense.id);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted ${expense.displayTitle}')));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onDelete});

  final VoidCallback onBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon: Icons.chevron_left_rounded, onTap: onBack),
        Expanded(
          child: Text(
            'Expense',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        _IconBox(icon: Icons.more_vert_rounded, onTap: onDelete),
      ],
    );
  }
}

class _HeroAmount extends StatelessWidget {
  const _HeroAmount({required this.expense});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: expense.category.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: expense.category.color.withValues(alpha: 0.42),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: 72,
            child: Icon(expense.category.icon, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          expense.amountLabel,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          expense.displayTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.inkMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ExpenseInfoCard extends StatelessWidget {
  const _ExpenseInfoCard({required this.expense});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkInkMuted : AppColors.line,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Category',
            value: expense.category.label,
            color: expense.category.color,
          ),
          _InfoRow(label: 'Date', value: expense.dateLabel),
          _InfoRow(label: 'Payment', value: expense.paymentMethod.label),
          _InfoRow(
            label: 'Note',
            value: expense.note?.trim().isEmpty ?? true
                ? '-'
                : expense.note!.trim(),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.color,
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkSubtle),
              ),
            ),
            if (color != null) ...[
              DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox.square(dimension: 9),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox.square(
          dimension: 54,
          child: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isDark ? AppColors.darkInkMuted : AppColors.line,
          ),
        ),
        child: SizedBox.square(dimension: 34, child: Icon(icon, size: 18)),
      ),
    );
  }
}
