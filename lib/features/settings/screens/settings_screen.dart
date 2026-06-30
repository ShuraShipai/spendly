import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/danger_action.dart';
import '../widgets/mint_switch.dart';
import '../widgets/profile_card.dart';
import '../widgets/settings_divider.dart';
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
          SettingsSection(
            children: [
              const SettingsRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                value: '₹ INR',
              ),
              const SettingsDivider(),
              const SettingsRow(
                icon: Icons.calendar_month_rounded,
                title: 'Week starts on',
                value: 'Monday',
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
          const SettingsSection(
            children: [
              SettingsRow(
                icon: Icons.notifications_rounded,
                title: 'Budget alerts',
                iconBackground: AppColors.warningSurface,
                iconColor: AppColors.warning,
                trailing: MintSwitch(value: true),
              ),
              SettingsDivider(),
              SettingsRow(
                icon: Icons.download_rounded,
                title: 'Export data',
                value: 'CSV',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DangerAction(
            label: authProvider.isLoading ? 'Signing out...' : 'Sign out',
            onPressed: authProvider.isLoading
                ? null
                : context.read<AuthProvider>().logout,
          ),
          const SizedBox(height: AppSpacing.sm),
          const DangerAction(label: 'Delete account'),
        ],
      ),
    );
  }
}
