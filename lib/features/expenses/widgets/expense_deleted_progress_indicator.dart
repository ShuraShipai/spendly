import 'package:flutter/material.dart';

class ExpenseDeletedProgressIndicator extends StatelessWidget {
  const ExpenseDeletedProgressIndicator({required this.duration, super.key});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      builder: (context, value, _) {
        return SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2.6,
            backgroundColor: colorScheme.onInverseSurface.withValues(
              alpha: 0.22,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
      },
    );
  }
}
