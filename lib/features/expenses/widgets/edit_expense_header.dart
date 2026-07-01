import 'package:flutter/material.dart';

class EditExpenseHeader extends StatelessWidget {
  const EditExpenseHeader({
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        Expanded(
          child: Text(
            'Edit expense',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(onPressed: onSave, child: const Text('Save')),
      ],
    );
  }
}
