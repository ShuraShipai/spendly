import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';

class AuthIconPanel extends StatelessWidget {
  const AuthIconPanel({required this.icon, this.size = 96, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.mintTint,
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Icon(icon, color: AppColors.mintDark, size: size * 0.48),
    );
  }
}
