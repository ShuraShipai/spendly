import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseAmountRangeThumb extends StatelessWidget {
  const ExpenseAmountRangeThumb({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.mint, width: 3),
      ),
      child: const SizedBox.square(dimension: 16),
    );
  }
}
