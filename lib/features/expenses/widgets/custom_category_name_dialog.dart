import 'package:flutter/material.dart';

class CustomCategoryNameDialog extends StatefulWidget {
  const CustomCategoryNameDialog({super.key});

  @override
  State<CustomCategoryNameDialog> createState() =>
      _CustomCategoryNameDialogState();
}

class _CustomCategoryNameDialogState extends State<CustomCategoryNameDialog> {
  late final TextEditingController _controller;
  var _showError = false;

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

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Add category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_showError) {
            setState(() => _showError = false);
          }
        },
        decoration: InputDecoration(
          hintText: 'e.g., Gym',
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          errorText: _showError ? 'Enter a category name' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
