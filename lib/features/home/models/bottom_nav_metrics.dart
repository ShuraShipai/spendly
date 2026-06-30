import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Responsive layout values for the main bottom navigation shell.
///
/// Baseline values match the spendly-design reference at 390 logical px width.
class BottomNavMetrics {
  const BottomNavMetrics({
    required this.barHeight,
    required this.iconSize,
    required this.buttonSize,
    required this.horizontalPadding,
    required this.labelSize,
    required this.fabSize,
    required this.fabIconSize,
    required this.fabBottomGap,
    required this.fabHorizontalMargin,
    required this.bottomSafePadding,
  });

  static const referenceWidth = 390.0;

  static const _baseBarHeight = 62.0;
  static const _baseIconSize = 22.0;
  static const _baseButtonSize = 54.0;
  static const _baseHorizontalPadding = AppSpacing.xs;
  static const _baseLabelSize = 11.0;
  static const _baseFabSize = 58.0;
  static const _baseFabIconSize = 26.0;
  static const _baseFabBottomGap = 22.0;
  static const _baseFabHorizontalMargin = 20.0;

  final double barHeight;
  final double iconSize;
  final double buttonSize;
  final double horizontalPadding;
  final double labelSize;
  final double fabSize;
  final double fabIconSize;
  final double fabBottomGap;
  final double fabHorizontalMargin;
  final double bottomSafePadding;

  double get totalBarHeight => barHeight + bottomSafePadding;

  factory BottomNavMetrics.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final bottomInset = mediaQuery.padding.bottom;
    final textScale = mediaQuery.textScaler.scale(1).clamp(0.85, 1.25);

    final widthScale = (width / referenceWidth).clamp(0.82, 1.18);
    final scale = widthScale * (0.92 + 0.08 * textScale);

    double scaled(double base) => base * scale;

    return BottomNavMetrics(
      barHeight: scaled(_baseBarHeight),
      iconSize: scaled(_baseIconSize),
      buttonSize: scaled(_baseButtonSize),
      horizontalPadding: math.max(
        AppSpacing.xxs,
        _baseHorizontalPadding * widthScale,
      ),
      labelSize: _baseLabelSize * textScale,
      fabSize: scaled(_baseFabSize),
      fabIconSize: scaled(_baseFabIconSize),
      fabBottomGap: scaled(_baseFabBottomGap),
      fabHorizontalMargin: scaled(_baseFabHorizontalMargin),
      bottomSafePadding: bottomInset > 0 ? bottomInset : AppSpacing.xxs,
    );
  }
}
