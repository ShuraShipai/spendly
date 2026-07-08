import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/expense_sort_option.dart';
import '../models/payment_method.dart';
import 'expense_filter_sheet.dart';
import 'expense_sort_sheet.dart';

class ExpenseListSheetLauncher {
  const ExpenseListSheetLauncher._();

  static void showSortSheet({
    required BuildContext context,
    required ExpenseSortOption selectedOption,
    required ValueChanged<ExpenseSortOption> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ExpenseSortSheet(
          selectedOption: selectedOption,
          onSelected: (option) {
            Navigator.of(context).pop();
            onSelected(option);
          },
        );
      },
    );
  }

  static void showFilterSheet({
    required BuildContext context,
    required List<ExpenseCategory> categories,
    required Set<String> selectedCategoryIds,
    required Set<PaymentMethod> selectedPaymentMethods,
    required void Function(Set<String>, Set<PaymentMethod>) onApply,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ExpenseFilterSheet(
          categories: categories,
          selectedCategoryIds: selectedCategoryIds,
          selectedPaymentMethods: selectedPaymentMethods,
          onApply: (categoryIds, paymentMethods) {
            Navigator.of(context).pop();
            onApply(categoryIds, paymentMethods);
          },
        );
      },
    );
  }
}
