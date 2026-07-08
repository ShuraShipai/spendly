import 'package:flutter/material.dart';

import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/models/app_user.dart';
import 'danger_action.dart';
import 'mint_switch.dart';
import 'profile_card.dart';
import 'settings_divider.dart';
import 'settings_navigation_card.dart';
import 'settings_option_sheet.dart';
import 'settings_row.dart';
import 'settings_section.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({
    required this.user,
    required this.appState,
    required this.isAuthLoading,
    required this.platformBrightness,
    required this.onEditProfile,
    required this.onOpenCategories,
    required this.onOpenCategoryBudgets,
    required this.onOpenNotifications,
    required this.onCurrencySelected,
    required this.onWeekStartSelected,
    required this.onThemeModeChanged,
    required this.onBudgetAlertsChanged,
    required this.onExportData,
    required this.onSignOut,
    required this.onDeleteAccount,
    required this.onShowOptionSheet,
    super.key,
  });

  final AppUser? user;
  final AppStateProvider appState;
  final bool isAuthLoading;
  final Brightness platformBrightness;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenCategoryBudgets;
  final VoidCallback onOpenNotifications;
  final ValueChanged<CurrencyPreference> onCurrencySelected;
  final ValueChanged<WeekStartPreference> onWeekStartSelected;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<bool> onBudgetAlertsChanged;
  final VoidCallback onExportData;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;
  final SettingsOptionSheetLauncher onShowOptionSheet;

  @override
  Widget build(BuildContext context) {
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
            photoUrl: user?.photoUrl,
            onTap: onEditProfile,
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsNavigationCard(
            icon: Icons.category_rounded,
            title: 'Categories',
            subtitle: 'View defaults and add custom categories.',
            onTap: onOpenCategories,
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsNavigationCard(
            icon: Icons.savings_rounded,
            title: 'Category Budgets',
            subtitle: 'Set limits for each spending category.',
            iconBackground: AppColors.warningSurface,
            iconColor: AppColors.warning,
            onTap: onOpenCategoryBudgets,
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSection(
            children: [
              SettingsRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                value: appState.currency.label,
                onTap: () => onShowOptionSheet<CurrencyPreference>(
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
                  onSelected: onCurrencySelected,
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.calendar_month_rounded,
                title: 'Week starts on',
                value: appState.weekStart.label,
                onTap: () => onShowOptionSheet<WeekStartPreference>(
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
                  onSelected: onWeekStartSelected,
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.dark_mode_rounded,
                title: 'Dark mode',
                trailing: MintSwitch(
                  value: appState.isDarkModeActive(platformBrightness),
                  onChanged: (value) {
                    onThemeModeChanged(
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
                onTap: onOpenNotifications,
                trailing: MintSwitch(
                  value: appState.budgetAlertsEnabled,
                  onChanged: onBudgetAlertsChanged,
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.download_rounded,
                title: 'Export data',
                value: 'CSV',
                onTap: onExportData,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DangerAction(
            label: isAuthLoading ? 'Signing out...' : 'Sign out',
            onPressed: isAuthLoading ? null : onSignOut,
          ),
          const SizedBox(height: AppSpacing.sm),
          DangerAction(
            label: 'Delete account',
            onPressed: isAuthLoading ? null : onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

typedef SettingsOptionSheetLauncher =
    void Function<T>({
      required String title,
      required List<SettingsOption<T>> options,
      required T selectedValue,
      required ValueChanged<T> onSelected,
    });
