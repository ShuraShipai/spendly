import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseTheme {
  const ExpenseTheme._();

  static Color surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color outline(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  static Color muted(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color subtle(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.72 : 0.78,
    );
  }

  static Color mintContainer(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  static Color onMintContainer(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  static Color dangerContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.danger.withValues(alpha: 0.18)
        : AppColors.dangerSurface;
  }

  static Color onBrand(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }
}
