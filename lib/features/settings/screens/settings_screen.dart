import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/danger_action.dart';
import '../widgets/destructive_confirmation_dialog.dart';
import '../widgets/mint_switch.dart';
import '../widgets/profile_card.dart';
import '../widgets/settings_divider.dart';
import '../widgets/settings_navigation_card.dart';
import '../widgets/settings_option_sheet.dart';
import '../widgets/settings_row.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final user = authProvider.user;
    final displayName = user?.displayName;
    final profileName = displayName == null || displayName.isEmpty
        ? 'Signed in'
        : displayName;

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
          SettingsNavigationCard(
            icon: Icons.category_rounded,
            title: 'Categories',
            subtitle: 'View defaults and add custom categories.',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.categories),
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsNavigationCard(
            icon: Icons.savings_rounded,
            title: 'Category Budgets',
            subtitle: 'Set limits for each spending category.',
            iconBackground: AppColors.warningSurface,
            iconColor: AppColors.warning,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.categoryBudgets),
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
}
