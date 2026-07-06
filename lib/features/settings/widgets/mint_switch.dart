import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MintSwitch extends StatelessWidget {
  const MintSwitch({required this.value, this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.mint : colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const SizedBox.square(dimension: 20),
            ),
          ),
        ),
      ),
    );
  }
}
