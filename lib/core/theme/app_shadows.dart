import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x1F3C504B), blurRadius: 34, offset: Offset(0, 12)),
  ];

  static const mintButton = [
    BoxShadow(color: Color(0x6634C6A8), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const inputFocus = [
    BoxShadow(color: AppColors.mintTint, blurRadius: 0, spreadRadius: 4),
  ];
}
