import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../app/providers/app_state_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../reports/providers/reports_provider.dart';
import '../../reports/widgets/export_report_dialog.dart';
import '../widgets/destructive_confirmation_dialog.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/settings_body.dart';
import '../widgets/settings_option_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    return SettingsBody(
      user: authProvider.user,
      appState: appState,
      isAuthLoading: authProvider.isLoading,
      platformBrightness: platformBrightness,
      onEditProfile: () => _showEditProfileSheet(context),
      onOpenCategories: () =>
          Navigator.of(context).pushNamed(AppRoutes.categories),
      onOpenCategoryBudgets: () =>
          Navigator.of(context).pushNamed(AppRoutes.categoryBudgets),
      onOpenNotifications: () =>
          Navigator.of(context).pushNamed(AppRoutes.notifications),
      onCurrencySelected: context.read<AppStateProvider>().setCurrency,
      onWeekStartSelected: context.read<AppStateProvider>().setWeekStart,
      onThemeModeChanged: context.read<AppStateProvider>().setThemeMode,
      onBudgetAlertsChanged: context
          .read<AppStateProvider>()
          .setBudgetAlertsEnabled,
      onExportData: () => _showExportDialog(context),
      onSignOut: () => _confirmSignOut(context),
      onDeleteAccount: () => _confirmDeleteAccount(context),
      onShowOptionSheet:
          <T>({
            required title,
            required options,
            required selectedValue,
            required onSelected,
          }) => _showOptionSheet<T>(
            context: context,
            title: title,
            options: options,
            selectedValue: selectedValue,
            onSelected: onSelected,
          ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final reportsProvider = context.read<ReportsProvider>();
    showDialog<void>(
      context: context,
      builder: (_) =>
          ExportReportDialog(csv: reportsProvider.monthlyCsv(DateTime.now())),
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

  void _showEditProfileSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditProfileSheet(
        displayName: user.displayName ?? '',
        email: user.email,
        photoUrl: user.photoUrl,
        onSave: ({required displayName, required photoUrl}) async {
          await authProvider.updateProfile(
            displayName: displayName,
            photoUrl: photoUrl,
          );
          return authProvider.errorMessage == null;
        },
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
