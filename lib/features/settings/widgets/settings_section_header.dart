import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.mintDark),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
