import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/reports_provider.dart';
import '../widgets/category_breakdown_list.dart';
import '../widgets/empty_reports_state.dart';
import '../widgets/export_report_button.dart';
import '../widgets/export_report_dialog.dart';
import '../widgets/report_metric_card.dart';
import '../widgets/reports_header.dart';
import '../widgets/reports_total_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final referenceDate = DateTime.now();
    final summary = reportsProvider.monthlySummary(referenceDate);
    final biggestExpense = summary.biggestExpense;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          ReportsHeader(monthLabel: _monthName(referenceDate)),
          const SizedBox(height: AppSpacing.md),
          ReportsTotalCard(
            total: summary.total,
            previousTotal: summary.previousTotal,
            referenceDate: referenceDate,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ReportMetricCard(
                  label: 'BIGGEST EXPENSE',
                  value: biggestExpense == null
                      ? '₹0'
                      : _formatAmount(biggestExpense.amount),
                  caption: biggestExpense == null
                      ? 'No expenses yet'
                      : '${biggestExpense.category.label} · ${biggestExpense.dateLabel}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ReportMetricCard(
                  label: 'DAILY AVERAGE',
                  value: _formatAmount(summary.dailyAverage),
                  caption: 'over ${referenceDate.day} days',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (summary.expenses.isEmpty)
            const EmptyReportsState()
          else
            CategoryBreakdownList(
              summaries: summary.categorySummaries,
              total: summary.total,
            ),
          const SizedBox(height: AppSpacing.md),
          ExportReportButton(
            onPressed: () => _showExportDialog(
              context,
              reportsProvider.monthlyCsv(referenceDate),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _monthName(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[date.month - 1];
  }

  void _showExportDialog(BuildContext context, String csv) {
    showDialog<void>(
      context: context,
      builder: (_) => ExportReportDialog(csv: csv),
    );
  }
}
