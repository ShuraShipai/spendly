import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/password_strength.dart';

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final strength = PasswordStrengthEvaluator.evaluate(value.text);
        final textColor = strength.level == PasswordStrengthLevel.strong
            ? AppColors.mintDark
            : strength.color;

        return Row(
          children: [
            for (var index = 0; index < 4; index++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index < strength.activeSegments
                        ? strength.color
                        : AppColors.line,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ),
              if (index != 3) const SizedBox(width: AppSpacing.xs),
            ],
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 54,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  strength.label,
                  key: ValueKey(strength.label),
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: textColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
