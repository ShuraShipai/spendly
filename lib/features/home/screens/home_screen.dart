import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/models/expense_entry.dart';
import '../../expenses/providers/expense_provider.dart';
import '../models/dashboard_period.dart';
import '../providers/dashboard_period_provider.dart';
import '../widgets/email_verification_banner.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/home_header.dart';
import '../widgets/period_selector.dart';
import '../widgets/period_spend_card.dart';
import '../widgets/recent_expenses_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _showEmailBanner = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final dashboardState = context.watch<DashboardPeriodProvider>();
    final appState = context.watch<AppStateProvider>();
    final user = authProvider.user;
    final displayName = user?.displayName;
    final firstName = displayName == null || displayName.isEmpty
        ? null
        : displayName.split(' ').first;
    final greeting = firstName == null ? 'Hi there' : 'Hi $firstName';
    final shouldShowEmailBanner =
        _showEmailBanner && !authProvider.isEmailVerified;
    final selectedPeriod = dashboardState.selectedPeriod;
    final referenceDate = DateTime.now();
    final dashboardExpenses = _expensesForPeriod(
      expenseProvider,
      selectedPeriod,
      referenceDate,
      appState.weekStart,
    );
    final dashboardTotal = _totalForPeriod(
      expenseProvider,
      selectedPeriod,
      referenceDate,
      appState.weekStart,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          HomeHeader(
            greeting: greeting,
            displayName: displayName,
            photoUrl: user?.photoUrl,
            onProfileTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
          if (shouldShowEmailBanner) ...[
            const SizedBox(height: AppSpacing.md),
            EmailVerificationBanner(
              email: user?.email ?? '',
              isLoading: authProvider.isLoading,
              onResend: context.read<AuthProvider>().sendEmailVerification,
              onDismiss: () {
                setState(() => _showEmailBanner = false);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          PeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodSelected: (period) {
              context.read<DashboardPeriodProvider>().setSelectedPeriod(period);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          PeriodSpendCard(
            totalSpent: dashboardTotal,
            period: selectedPeriod,
            referenceDate: referenceDate,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (dashboardExpenses.isEmpty)
            const EmptyExpenseState()
          else
            RecentExpensesList(
              expenses: dashboardExpenses,
              onExpenseTap: (expense) => _openExpenseDetail(context, expense),
            ),
        ],
      ),
    );
  }

  void _openExpenseDetail(BuildContext context, ExpenseEntry expense) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.expenseDetail, arguments: expense.id);
  }

  List<ExpenseEntry> _expensesForPeriod(
    ExpenseProvider provider,
    DashboardPeriod period,
    DateTime referenceDate,
    WeekStartPreference weekStart,
  ) {
    return switch (period) {
      DashboardPeriod.today => provider.expensesForDay(referenceDate),
      DashboardPeriod.week => provider.expensesForWeek(
        referenceDate,
        weekStartsOn: _weekStartDay(weekStart),
      ),
      DashboardPeriod.month => provider.expensesForMonth(referenceDate),
    };
  }

  double _totalForPeriod(
    ExpenseProvider provider,
    DashboardPeriod period,
    DateTime referenceDate,
    WeekStartPreference weekStart,
  ) {
    return switch (period) {
      DashboardPeriod.today => provider.totalSpentForDay(referenceDate),
      DashboardPeriod.week => provider.totalSpentForWeek(
        referenceDate,
        weekStartsOn: _weekStartDay(weekStart),
      ),
      DashboardPeriod.month => provider.totalSpentForMonth(referenceDate),
    };
  }

  int _weekStartDay(WeekStartPreference weekStart) {
    return switch (weekStart) {
      WeekStartPreference.monday => DateTime.monday,
      WeekStartPreference.sunday => DateTime.sunday,
    };
  }
}
