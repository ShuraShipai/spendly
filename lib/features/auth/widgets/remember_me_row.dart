import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class RememberMeRow extends StatelessWidget {
  const RememberMeRow({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.mint : AppColors.card,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: value ? AppColors.mint : AppColors.line,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Remember me',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
          child: const Text('Forgot?'),
        ),
      ],
    );
  }
}
