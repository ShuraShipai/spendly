import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'expense_theme.dart';

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
  late final FocusNode _focusNode;
  var _lastBottomInset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
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
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      return;
    }

    _ensureVisible();
  }

  void _ensureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.85,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    if (bottomInset != _lastBottomInset) {
      _lastBottomInset = bottomInset;
      if (_focusNode.hasFocus) {
        _ensureVisible();
      }
    }

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      minLines: 1,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Add a note (optional)...',
        hintStyle: Theme.of(context).textTheme.bodySmall,
        filled: true,
        fillColor: ExpenseTheme.surface(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: ExpenseTheme.outline(context),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
      ),
    );
  }
}
