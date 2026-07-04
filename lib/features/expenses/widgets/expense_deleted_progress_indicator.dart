import 'package:flutter/material.dart';

class ExpenseDeletedProgressIndicator extends StatelessWidget {
  const ExpenseDeletedProgressIndicator({required this.duration, super.key});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      builder: (context, value, _) {
        return SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2.6,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8FD884)),
          ),
        );
      },
    );
  }
}
