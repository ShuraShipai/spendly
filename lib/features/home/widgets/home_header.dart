import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.greeting,
    required this.displayName,
    super.key,
  });

  final String greeting;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final initial = displayName == null || displayName!.isEmpty
        ? 'S'
        : displayName![0].toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.bodySmall),
              Text(
                'Good evening',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB0A4F5), Color(0xFF8C7DF0)],
            ),
          ),
          child: SizedBox.square(
            dimension: 36,
            child: Center(
              child: Text(
                initial,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
