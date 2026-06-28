import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppTextLink extends StatelessWidget {
  const AppTextLink({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mintDark,
        textStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}
