import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/budget_amount_sheet.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/category_budget_row.dart';
import '../widgets/category_management_row.dart';
import '../widgets/danger_action.dart';
import '../widgets/destructive_confirmation_dialog.dart';
import '../widgets/mint_switch.dart';
import '../widgets/profile_card.dart';
import '../widgets/settings_divider.dart';
import '../widgets/settings_option_sheet.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _loadedCategoryUserId;
  var _hasLoadedCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().user?.uid;
    if (_hasLoadedCategories && _loadedCategoryUserId == uid) {
      return;
    }
    _loadedCategoryUserId = uid;
    _hasLoadedCategories = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(context.read<SettingsProvider>().loadCategories(uid));
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final user = authProvider.user;
    final displayName = user?.displayName;
    final profileName = displayName == null || displayName.isEmpty
        ? 'Signed in'
        : displayName;
    final categories = settingsProvider.categories;
    final totalSpent = expenseProvider.totalSpentForMonth(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ProfileCard(
            title: profileName,
            subtitle: user?.email ?? 'No email available',
          ),
          const SizedBox(height: AppSpacing.md),
          BudgetOverviewCard(
            budget: settingsProvider.monthlyBudget,
            spent: totalSpent,
            alertsEnabled: appState.budgetAlertsEnabled,
            onEdit: () => _showBudgetSheet(
              title: 'Monthly budget',
              initialAmount: settingsProvider.monthlyBudget,
              onSave: context.read<SettingsProvider>().setMonthlyBudget,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSectionHeader(
            title: 'CATEGORY BUDGETS',
            actionLabel: 'Reset',
            onAction: _resetCategoryBudgets,
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsSection(
            children: [
              for (final category in categories) ...[
                CategoryBudgetRow(
                  category: category,
                  budget: settingsProvider.budgetForCategory(category.id),
                  spent: _spentForCategory(expenseProvider, category),
                  onTap: () => _showBudgetSheet(
                    title: '${category.label} budget',
                    initialAmount: settingsProvider.budgetForCategory(
                      category.id,
                    ),
                    onSave: (amount) => context
                        .read<SettingsProvider>()
                        .setCategoryBudget(category.id, amount),
                  ),
                ),
                if (category != categories.last) const SettingsDivider(),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSectionHeader(
            title: 'CATEGORIES',
            actionLabel: 'Add',
            onAction: () => _showAddCategorySheet(user?.uid),
          ),
          const SizedBox(height: AppSpacing.xs),
          SettingsSection(
            children: [
              for (final category in categories) ...[
                CategoryManagementRow(
                  category: category,
                  onDelete: category.isCustom
                      ? () => _confirmDeleteCategory(user?.uid, category)
                      : null,
                ),
                if (category != categories.last) const SettingsDivider(),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSection(
            children: [
              SettingsRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                value: appState.currency.label,
                onTap: () => _showOptionSheet<CurrencyPreference>(
                  context: context,
                  title: 'Currency',
                  selectedValue: appState.currency,
                  options: CurrencyPreference.values
                      .map(
                        (currency) => SettingsOption(
                          value: currency,
                          label: currency.label,
                        ),
                      )
                      .toList(growable: false),
                  onSelected: context.read<AppStateProvider>().setCurrency,
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.calendar_month_rounded,
                title: 'Week starts on',
                value: appState.weekStart.label,
                onTap: () => _showOptionSheet<WeekStartPreference>(
                  context: context,
                  title: 'Week starts on',
                  selectedValue: appState.weekStart,
                  options: WeekStartPreference.values
                      .map(
                        (weekStart) => SettingsOption(
                          value: weekStart,
                          label: weekStart.label,
                        ),
                      )
                      .toList(growable: false),
                  onSelected: context.read<AppStateProvider>().setWeekStart,
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.dark_mode_rounded,
                title: 'Dark mode',
                trailing: MintSwitch(
                  value: appState.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    context.read<AppStateProvider>().setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSection(
            children: [
              SettingsRow(
                icon: Icons.notifications_rounded,
                title: 'Budget alerts',
                iconBackground: AppColors.warningSurface,
                iconColor: AppColors.warning,
                trailing: MintSwitch(
                  value: appState.budgetAlertsEnabled,
                  onChanged: context
                      .read<AppStateProvider>()
                      .setBudgetAlertsEnabled,
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.download_rounded,
                title: 'Export data',
                value: 'CSV',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Open Insights to export monthly CSV.'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DangerAction(
            label: authProvider.isLoading ? 'Signing out...' : 'Sign out',
            onPressed: authProvider.isLoading
                ? null
                : () => _confirmSignOut(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          DangerAction(
            label: 'Delete account',
            onPressed: authProvider.isLoading
                ? null
                : () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  double _spentForCategory(
    ExpenseProvider expenseProvider,
    ExpenseCategory category,
  ) {
    return expenseProvider
        .expensesForMonth(DateTime.now())
        .where((expense) => expense.category.id == category.id)
        .fold<double>(0, (total, expense) => total + expense.amount);
  }

  void _showBudgetSheet({
    required String title,
    required double initialAmount,
    required ValueChanged<double> onSave,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BudgetAmountSheet(
        title: title,
        initialAmount: initialAmount,
        onSave: onSave,
      ),
    );
  }

  void _showAddCategorySheet(String? uid) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddCategorySheet(
        onSave: (label) {
          unawaited(
            context.read<SettingsProvider>().addCustomCategory(
              uid: uid,
              label: label,
            ),
          );
        },
      ),
    );
  }

  void _resetCategoryBudgets() {
    final settingsProvider = context.read<SettingsProvider>();
    for (final category in settingsProvider.categories) {
      settingsProvider.setCategoryBudget(category.id, 0);
    }
  }

  void _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required List<SettingsOption<T>> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SettingsOptionSheet<T>(
        title: title,
        options: options,
        selectedValue: selectedValue,
        onSelected: onSelected,
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (_) => const DestructiveConfirmationDialog(
        title: 'Sign out?',
        message: 'You can sign back in with your email and password.',
        confirmLabel: 'Sign out',
      ),
    );

    if (shouldSignOut ?? false) {
      if (!context.mounted) {
        return;
      }
      await context.read<AuthProvider>().logout();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => const DestructiveConfirmationDialog(
        title: 'Delete account?',
        message: 'This removes your Spendly profile and cannot be undone.',
        confirmLabel: 'Delete',
      ),
    );

    if (shouldDelete ?? false) {
      if (!context.mounted) {
        return;
      }
      await context.read<AuthProvider>().deleteAccount();
    }
  }

  Future<void> _confirmDeleteCategory(
    String? uid,
    ExpenseCategory category,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => DestructiveConfirmationDialog(
        title: 'Delete ${category.label}?',
        message:
            'Existing expenses keep their category, but it is removed from future pickers.',
        confirmLabel: 'Delete',
      ),
    );

    if (shouldDelete ?? false) {
      if (!mounted) {
        return;
      }
      await context.read<SettingsProvider>().deleteCustomCategory(
        uid: uid,
        category: category,
      );
    }
  }
}
