import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsOption<T> {
  const SettingsOption({required this.value, required this.label});

  final T value;
  final String label;
}

class SettingsOptionSheet<T> extends StatelessWidget {
  const SettingsOptionSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  final String title;
  final List<SettingsOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.inkSubtle.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox(width: 42, height: 4),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: Column(
                children: [
                  for (final option in options)
                    ListTile(
                      onTap: () {
                        onSelected(option.value);
                        Navigator.of(context).pop();
                      },
                      title: Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: option.value == selectedValue
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.mint,
                            )
                          : null,
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
