import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

class EditAmountEditor extends StatelessWidget {
  const EditAmountEditor({
    required this.controller,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExpenseTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mint, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ExpenseTheme.subtle(context),
              ),
            ),
            TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
              decoration: InputDecoration(
                prefixText: '₹',
                errorText: errorText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
