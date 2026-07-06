import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../expenses/widgets/mint_action_button.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({required this.onSave, super.key});

  final Future<bool> Function(String label) onSave;

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  late final TextEditingController _controller;
  String? _errorText;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_isSaving) {
                  _save();
                }
              },
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'e.g., Gym',
                errorText: _errorText,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            MintActionButton(
              label: _isSaving ? 'Saving...' : 'Save category',
              onPressed: _save,
              isEnabled: !_isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final label = _controller.text.trim();
    if (label.isEmpty) {
      setState(() => _errorText = 'Enter a category name');
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    final saved = await widget.onSave(label);
    if (!mounted) {
      return;
    }

    if (!saved) {
      setState(() {
        _errorText = 'Could not save category. Please try again.';
        _isSaving = false;
      });
      return;
    }

    Navigator.of(context).pop();
  }
}
