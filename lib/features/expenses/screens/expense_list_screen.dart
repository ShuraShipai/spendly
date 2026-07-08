import 'package:flutter/material.dart';

import '../widgets/expense_list_body.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({
    this.temporaryStateResetToken = 0,
    this.onSearchModeChanged,
    super.key,
  });

  final int temporaryStateResetToken;
  final ValueChanged<bool>? onSearchModeChanged;

  @override
  Widget build(BuildContext context) {
    return ExpenseListBody(
      temporaryStateResetToken: temporaryStateResetToken,
      onSearchModeChanged: onSearchModeChanged,
    );
  }
}
