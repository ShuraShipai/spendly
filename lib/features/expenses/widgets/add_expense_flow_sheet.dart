import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import 'amount_keypad_step.dart';
import 'expense_details_step.dart';

class AddExpenseFlowSheet extends StatefulWidget {
  const AddExpenseFlowSheet({super.key});

  @override
  State<AddExpenseFlowSheet> createState() => _AddExpenseFlowSheetState();
}

class _AddExpenseFlowSheetState extends State<AddExpenseFlowSheet> {
  var _step = _ExpenseStep.amount;
  var _amount = '0';
  var _category = ExpenseCategory.food;

  void _appendAmount(String value) {
    setState(() {
      if (value == '.' && _amount.contains('.')) {
        return;
      }
      if (_amount == '0' && value != '.') {
        _amount = value;
        return;
      }
      _amount += value;
    });
  }

  void _backspaceAmount() {
    setState(() {
      if (_amount.length <= 1) {
        _amount = '0';
        return;
      }
      _amount = _amount.substring(0, _amount.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAmountStep = _step == _ExpenseStep.amount;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: isAmountStep
          ? AmountKeypadStep(
              key: const ValueKey('amount'),
              amount: _amount,
              category: _category,
              onClose: () => Navigator.of(context).pop(),
              onKeyPressed: _appendAmount,
              onBackspace: _backspaceAmount,
              onNext: () => setState(() => _step = _ExpenseStep.details),
            )
          : ExpenseDetailsStep(
              key: const ValueKey('details'),
              amount: _amount,
              category: _category,
              onClose: () => Navigator.of(context).pop(),
              onBack: () => setState(() => _step = _ExpenseStep.amount),
              onCategoryChanged: (category) {
                setState(() => _category = category);
              },
              onSave: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved ₹$_amount ${_category.label} expense'),
                  ),
                );
              },
            ),
    );
  }
}

enum _ExpenseStep { amount, details }
