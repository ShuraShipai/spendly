import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final textTheme = AppTextStyles.textTheme(Brightness.light);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.mint,
          brightness: Brightness.light,
          primary: AppColors.mint,
          surface: AppColors.card,
        ).copyWith(
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.inkMuted,
          outline: AppColors.line,
          outlineVariant: AppColors.line,
          primaryContainer: AppColors.mintTint,
          onPrimaryContainer: AppColors.mintDark,
          error: AppColors.danger,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData get dark {
    final textTheme = AppTextStyles.textTheme(Brightness.dark);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.mint,
          brightness: Brightness.dark,
          primary: AppColors.mint,
        ).copyWith(
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkInk,
          onSurfaceVariant: AppColors.darkInkMuted,
          outline: AppColors.darkInkMuted.withValues(alpha: 0.42),
          outlineVariant: AppColors.darkInkMuted.withValues(alpha: 0.28),
          primaryContainer: AppColors.mint.withValues(alpha: 0.18),
          onPrimaryContainer: AppColors.darkInk,
          error: AppColors.danger,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkInk,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
