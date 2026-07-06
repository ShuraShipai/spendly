import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

enum BudgetNotificationSeverity { exceeded, warning, normal }

class BudgetNotificationTile extends StatelessWidget {
  const BudgetNotificationTile({
    required this.severity,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.isUnread = false,
    this.onTap,
    super.key,
  });

  final BudgetNotificationSeverity severity;
  final String title;
  final String message;
  final String timeLabel;
  final bool isUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(severity);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: palette.surfaceColor(isDark),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: palette.borderColor(isDark)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox.square(
                  dimension: 36,
                  child: Icon(palette.icon, color: palette.accent, size: 19),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.titleColor(isDark),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: palette.bodyColor(isDark),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      timeLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: palette.timeColor(isDark),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _BudgetNotificationPalette _paletteFor(BudgetNotificationSeverity severity) {
    return switch (severity) {
      BudgetNotificationSeverity.exceeded => const _BudgetNotificationPalette(
        accent: AppColors.danger,
        icon: Icons.error_outline_rounded,
        surface: AppColors.dangerSurface,
        border: Color(0xFFFFD2C9),
        title: Color(0xFFC8503C),
        body: Color(0xFFC8604C),
        time: Color(0xFFD89A8E),
      ),
      BudgetNotificationSeverity.warning => const _BudgetNotificationPalette(
        accent: AppColors.warning,
        icon: Icons.warning_amber_rounded,
        surface: AppColors.warningSurface,
        border: Color(0xFFFFE0A8),
        title: Color(0xFF8A6914),
        body: Color(0xFF9A7A2C),
        time: Color(0xFFB89A5C),
      ),
      BudgetNotificationSeverity.normal => const _BudgetNotificationPalette(
        accent: AppColors.mintDark,
        icon: Icons.notifications_rounded,
        surface: AppColors.card,
        border: AppColors.line,
        title: AppColors.ink,
        body: AppColors.inkMuted,
        time: AppColors.inkSubtle,
      ),
    };
  }
}

class _BudgetNotificationPalette {
  const _BudgetNotificationPalette({
    required this.accent,
    required this.icon,
    required this.surface,
    required this.border,
    required this.title,
    required this.body,
    required this.time,
  });

  final Color accent;
  final IconData icon;
  final Color surface;
  final Color border;
  final Color title;
  final Color body;
  final Color time;

  Color surfaceColor(bool isDark) {
    if (!isDark) {
      return surface;
    }
    return severityTint.withValues(alpha: 0.16);
  }

  Color borderColor(bool isDark) {
    if (!isDark) {
      return border;
    }
    return accent.withValues(alpha: 0.32);
  }

  Color titleColor(bool isDark) => isDark ? AppColors.darkInk : title;

  Color bodyColor(bool isDark) => isDark ? AppColors.darkInkMuted : body;

  Color timeColor(bool isDark) =>
      isDark ? AppColors.darkInkMuted.withValues(alpha: 0.78) : time;

  Color get severityTint => accent;
}
