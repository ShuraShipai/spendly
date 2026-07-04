import 'package:flutter/material.dart';

import '../../../core/widgets/app_primary_button.dart';

class MintActionButton extends StatelessWidget {
  const MintActionButton({
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: label,
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
