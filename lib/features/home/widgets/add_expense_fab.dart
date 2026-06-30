import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/bottom_nav_metrics.dart';

class AddExpenseFab extends StatelessWidget {
  const AddExpenseFab({
    required this.metrics,
    required this.onPressed,
    super.key,
  });

  final BottomNavMetrics metrics;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: metrics.fabSize,
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: AppColors.mint,
        heroTag: 'add-expense',
        onPressed: onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: metrics.fabIconSize,
        ),
      ),
    );
  }
}

/// Positions the add-expense FAB above the bottom navigation bar with a
/// responsive gap that matches the spendly-design reference.
class SpendlyFabLocation extends FloatingActionButtonLocation {
  const SpendlyFabLocation(this.metrics);

  final BottomNavMetrics metrics;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;

    final fabX =
        scaffoldSize.width - fabSize.width - metrics.fabHorizontalMargin;
    final fabY =
        scaffoldGeometry.contentBottom - fabSize.height - metrics.fabBottomGap;

    return Offset(fabX, fabY);
  }
}
