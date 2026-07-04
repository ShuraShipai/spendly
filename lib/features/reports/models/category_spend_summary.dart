import '../../expenses/models/expense_category.dart';

class CategorySpendSummary {
  const CategorySpendSummary({required this.category, required this.total});

  final ExpenseCategory category;
  final double total;
}
