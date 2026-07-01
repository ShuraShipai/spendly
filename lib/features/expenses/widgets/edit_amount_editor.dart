import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class EditAmountEditor extends StatelessWidget {
  const EditAmountEditor({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mint, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3334C6A8),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'AMOUNT',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle),
            ),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
              decoration: const InputDecoration(prefixText: '₹'),
            ),
          ],
        ),
      ),
    );
  }
}
