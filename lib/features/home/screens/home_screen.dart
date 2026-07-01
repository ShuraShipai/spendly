import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../widgets/email_verification_banner.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/home_header.dart';
import '../widgets/period_selector.dart';
import '../widgets/recent_expenses_list.dart';
import '../widgets/weekly_spend_card.dart';

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
    final user = authProvider.user;
    final displayName = user?.displayName;
    final firstName = displayName == null || displayName.isEmpty
        ? null
        : displayName.split(' ').first;
    final greeting = firstName == null ? 'Hi there' : 'Hi $firstName';
    final shouldShowEmailBanner =
        _showEmailBanner && !authProvider.isEmailVerified;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          HomeHeader(greeting: greeting, displayName: displayName),
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
          const PeriodSelector(),
          const SizedBox(height: AppSpacing.xl),
          WeeklySpendCard(totalSpent: expenseProvider.totalSpent),
          const SizedBox(height: AppSpacing.xxl),
          if (expenseProvider.expenses.isEmpty)
            const EmptyExpenseState()
          else
            RecentExpensesList(expenses: expenseProvider.expenses),
        ],
      ),
    );
  }
}
