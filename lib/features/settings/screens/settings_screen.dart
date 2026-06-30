import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';

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
          _ProfileCard(
            title: profileName,
            subtitle: user?.email ?? 'No email available',
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            children: [
              const _SettingsRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                value: '₹ INR',
              ),
              const _SettingsDivider(),
              const _SettingsRow(
                icon: Icons.calendar_month_rounded,
                title: 'Week starts on',
                value: 'Monday',
              ),
              const _SettingsDivider(),
              _SettingsRow(
                icon: Icons.dark_mode_rounded,
                title: 'Dark mode',
                trailing: _MintSwitch(
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
          _SettingsSection(
            children: [
              const _SettingsRow(
                icon: Icons.notifications_rounded,
                title: 'Budget alerts',
                iconBackground: AppColors.warningSurface,
                iconColor: AppColors.warning,
                trailing: _MintSwitch(value: true),
              ),
              const _SettingsDivider(),
              const _SettingsRow(
                icon: Icons.download_rounded,
                title: 'Export data',
                value: 'CSV',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DangerAction(
            label: authProvider.isLoading ? 'Signing out...' : 'Sign out',
            onPressed: authProvider.isLoading
                ? null
                : context.read<AuthProvider>().logout,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _DangerAction(label: 'Delete account'),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;
    final borderColor = isDark ? AppColors.darkInkMuted : AppColors.line;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: borderColor.withValues(alpha: 0.28)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Column(children: children),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;
    final borderColor = isDark ? AppColors.darkInkMuted : AppColors.line;
    final initial = title.isEmpty ? 'S' : title[0].toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: borderColor.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB0A4F5), Color(0xFF8C7DF0)],
                ),
              ),
              child: SizedBox.square(
                dimension: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Text(
                        initial,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          shape: BoxShape.circle,
                          border: Border.all(color: surfaceColor, width: 2),
                        ),
                        child: const SizedBox.square(
                          dimension: 20,
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkInkMuted : AppColors.line;

    return Divider(
      height: 1,
      thickness: 1,
      indent: AppSpacing.lg,
      color: color.withValues(alpha: 0.22),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.iconBackground = AppColors.mintTint,
    this.iconColor = AppColors.mintDark,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final valueWidget = trailing;
    final textStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: SizedBox.square(
              dimension: 30,
              child: Icon(icon, color: iconColor, size: 17),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (valueWidget != null)
            valueWidget
          else if (value != null)
            Text('$value ›', style: textStyle),
        ],
      ),
    );
  }
}

class _MintSwitch extends StatelessWidget {
  const _MintSwitch({required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.mint : AppColors.line,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const SizedBox.square(dimension: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerAction extends StatelessWidget {
  const _DangerAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.danger,
          textStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}
