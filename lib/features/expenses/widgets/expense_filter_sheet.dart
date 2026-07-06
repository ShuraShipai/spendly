import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/expense_category.dart';
import '../models/payment_method.dart';
import 'expense_theme.dart';
import 'mint_action_button.dart';

class ExpenseFilterSheet extends StatefulWidget {
  const ExpenseFilterSheet({
    required this.categories,
    required this.selectedCategoryIds,
    required this.selectedPaymentMethods,
    required this.onApply,
    super.key,
  });

  final List<ExpenseCategory> categories;
  final Set<String> selectedCategoryIds;
  final Set<PaymentMethod> selectedPaymentMethods;
  final void Function(Set<String>, Set<PaymentMethod>) onApply;

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  late final Set<String> _categoryIds;
  late final Set<PaymentMethod> _paymentMethods;

  @override
  void initState() {
    super.initState();
    _categoryIds = {...widget.selectedCategoryIds};
    _paymentMethods = {...widget.selectedPaymentMethods};
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('CATEGORY', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final category in widget.categories)
                  FilterChip(
                    label: Text(category.label),
                    selected: _categoryIds.contains(category.id),
                    selectedColor: ExpenseTheme.mintContainer(context),
                    checkmarkColor: ExpenseTheme.onMintContainer(context),
                    backgroundColor: ExpenseTheme.surface(context),
                    side: BorderSide(color: ExpenseTheme.outline(context)),
                    labelStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurface),
                    onSelected: (_) => _toggleCategory(category.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('PAYMENT', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final method in PaymentMethod.values)
                  FilterChip(
                    label: Text(method.label),
                    selected: _paymentMethods.contains(method),
                    selectedColor: ExpenseTheme.mintContainer(context),
                    checkmarkColor: ExpenseTheme.onMintContainer(context),
                    backgroundColor: ExpenseTheme.surface(context),
                    side: BorderSide(color: ExpenseTheme.outline(context)),
                    labelStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurface),
                    onSelected: (_) => _togglePaymentMethod(method),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                TextButton(onPressed: _clear, child: const Text('Clear')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MintActionButton(
                    label: 'Apply filters',
                    onPressed: () {
                      widget.onApply(_categoryIds, _paymentMethods);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(String id) {
    setState(() {
      if (!_categoryIds.remove(id)) {
        _categoryIds.add(id);
      }
    });
  }

  void _togglePaymentMethod(PaymentMethod method) {
    setState(() {
      if (!_paymentMethods.remove(method)) {
        _paymentMethods.add(method);
      }
    });
  }

  void _clear() {
    setState(() {
      _categoryIds.clear();
      _paymentMethods.clear();
    });
  }
}
