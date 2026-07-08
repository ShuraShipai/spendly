import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../expenses/widgets/mint_action_button.dart';

class BudgetAmountSheet extends StatefulWidget {
  const BudgetAmountSheet({
    required this.title,
    required this.initialAmount,
    required this.onSave,
    super.key,
  });

  final String title;
  final double initialAmount;
  final ValueChanged<double> onSave;

  @override
  State<BudgetAmountSheet> createState() => _BudgetAmountSheetState();
}

class _BudgetAmountSheetState extends State<BudgetAmountSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialText);
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
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
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
            MintActionButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }

  String get _initialText {
    if (widget.initialAmount <= 0) {
      return '';
    }

    if (widget.initialAmount == widget.initialAmount.roundToDouble()) {
      return widget.initialAmount.round().toString();
    }
    return widget.initialAmount.toStringAsFixed(2);
  }

  void _save() {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount < 0) {
      setState(() => _errorText = 'Enter a valid amount');
      return;
    }

    widget.onSave(amount);
    Navigator.of(context).pop();
  }
}
