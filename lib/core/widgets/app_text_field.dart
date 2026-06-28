import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.trailing,
    this.focused = false,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final Widget? trailing;
  final bool focused;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError
        ? AppColors.dangerLine
        : focused
        ? AppColors.mint
        : AppColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: focused && !hasError ? AppShadows.inputFocus : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  initialValue: initialValue,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                  autofillHints: autofillHints,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: trailing,
                ),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
