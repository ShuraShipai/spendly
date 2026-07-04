import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExportReportButton extends StatelessWidget {
  const ExportReportButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.file_download_outlined, size: 17),
        label: const Text('Export CSV'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mintDark,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.card,
          side: const BorderSide(color: AppColors.mint, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
