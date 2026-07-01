import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ExpenseNoteField extends StatefulWidget {
  const ExpenseNoteField({
    required this.note,
    required this.onChanged,
    super.key,
  });

  final String note;
  final ValueChanged<String> onChanged;

  @override
  State<ExpenseNoteField> createState() => _ExpenseNoteFieldState();
}

class _ExpenseNoteFieldState extends State<ExpenseNoteField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
  }

  @override
  void didUpdateWidget(covariant ExpenseNoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note == _controller.text) {
      return;
    }

    _controller.text = widget.note;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      minLines: 1,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Add a note (optional)...',
        hintStyle: Theme.of(context).textTheme.bodySmall,
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
      ),
    );
  }
}
