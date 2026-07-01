import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/expense_entry.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list_tile.dart';
import 'expense_detail_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final groupedExpenses = _groupByDay(expenses);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Expenses',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              _HeaderIconButton(icon: Icons.search_rounded, onTap: () {}),
              const SizedBox(width: AppSpacing.xs),
              _HeaderIconButton(icon: Icons.tune_rounded, onTap: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (expenses.isEmpty)
            const _EmptyExpensesList()
          else
            for (final group in groupedExpenses) ...[
              _DayHeader(date: group.date, total: group.total),
              const SizedBox(height: AppSpacing.xs),
              for (final expense in group.expenses) ...[
                ExpenseListTile(
                  expense: expense,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ExpenseDetailScreen(expenseId: expense.id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }

  List<_ExpenseDayGroup> _groupByDay(List<ExpenseEntry> expenses) {
    final groups = <DateTime, List<ExpenseEntry>>{};
    for (final expense in expenses) {
      final day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      groups.putIfAbsent(day, () => []).add(expense);
    }

    final sortedDays = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in sortedDays)
        _ExpenseDayGroup(date: day, expenses: groups[day]!),
    ];
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

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
        child: SizedBox.square(dimension: 34, child: Icon(icon, size: 17)),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.total});

  final DateTime date;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _formatDate(date),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.inkMuted),
          ),
        ),
        Text(
          _formatAmount(total),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final yesterdayOnly = todayOnly.subtract(const Duration(days: 1));

    if (date == todayOnly) {
      return 'Today, ${date.day} ${_monthName(date)}';
    }
    if (date == yesterdayOnly) {
      return 'Yesterday, ${date.day} ${_monthName(date)}';
    }
    return '${date.day} ${_monthName(date)} ${date.year}';
  }

  String _monthName(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[date.month - 1];
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}

class _EmptyExpensesList extends StatelessWidget {
  const _EmptyExpensesList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: AppColors.inkSubtle,
            size: 54,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap + to add your first expense.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExpenseDayGroup {
  const _ExpenseDayGroup({required this.date, required this.expenses});

  final DateTime date;
  final List<ExpenseEntry> expenses;

  double get total {
    return expenses.fold<double>(0, (total, expense) => total + expense.amount);
  }
}
