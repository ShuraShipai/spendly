import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class ExpenseSheetFrame extends StatelessWidget {
  const ExpenseSheetFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        bottomInset;
    final sheetHeight = availableHeight.clamp(0.0, 640.0).toDouble();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: sheetHeight,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
