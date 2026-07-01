import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class ExpenseSheetFrame extends StatelessWidget {
  const ExpenseSheetFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: availableHeight < 640 ? availableHeight : 640,
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
    );
  }
}
