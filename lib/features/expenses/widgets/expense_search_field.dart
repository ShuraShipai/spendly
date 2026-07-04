import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ExpenseSearchField extends StatelessWidget {
  const ExpenseSearchField({
    required this.controller,
    required this.onChanged,
    required this.onCancel,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.card,
              border: Border.all(color: AppColors.mint, width: 1.5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.mintTint,
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              style: textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkInk : AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Search expenses',
                hintStyle: textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSubtle,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.mint,
                  size: 15,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 20,
                ),
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.fromLTRB(0, 11, 14, 11),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm - 2),
        GestureDetector(
          onTap: onCancel,
          child: Text(
            'Cancel',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
