import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkInkMuted : AppColors.inkMuted;

    return GoogleFonts.nunitoTextTheme().copyWith(
      displaySmall: GoogleFonts.nunito(
        fontSize: 34,
        height: 1.08,
        fontWeight: FontWeight.w900,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 30,
        height: 1.12,
        fontWeight: FontWeight.w900,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w900,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w900,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w800,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: mutedColor,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
    );
  }
}
