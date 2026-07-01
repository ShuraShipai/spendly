import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CelebrationConfettiRow extends StatelessWidget {
  const CelebrationConfettiRow({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.food,
      AppColors.transport,
      AppColors.bills,
      AppColors.rent,
      AppColors.shopping,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final color in colors)
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const SizedBox.square(dimension: 9),
          ),
      ],
    );
  }
}
