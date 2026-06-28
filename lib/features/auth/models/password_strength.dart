import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum PasswordStrengthLevel { empty, weak, fair, good, strong }

class PasswordStrength {
  const PasswordStrength({
    required this.level,
    required this.label,
    required this.activeSegments,
    required this.color,
  });

  final PasswordStrengthLevel level;
  final String label;
  final int activeSegments;
  final Color color;

  bool get isWarning {
    return level == PasswordStrengthLevel.fair ||
        level == PasswordStrengthLevel.good;
  }
}

class PasswordStrengthEvaluator {
  const PasswordStrengthEvaluator._();

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.empty,
        label: 'Required',
        activeSegments: 0,
        color: AppColors.inkSubtle,
      );
    }

    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp('[A-Z]').hasMatch(password)) score++;
    if (RegExp('[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    if (score <= 1) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.weak,
        label: 'Weak',
        activeSegments: 1,
        color: AppColors.danger,
      );
    }

    if (score == 2) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.fair,
        label: 'Fair',
        activeSegments: 2,
        color: AppColors.warning,
      );
    }

    if (score == 3) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.good,
        label: 'Good',
        activeSegments: 3,
        color: AppColors.warning,
      );
    }

    return const PasswordStrength(
      level: PasswordStrengthLevel.strong,
      label: 'Strong',
      activeSegments: 4,
      color: AppColors.mint,
    );
  }
}
