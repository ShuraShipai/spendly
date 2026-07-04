enum ExpenseFilterChipType { category, paymentMethod, amount }

class ExpenseFilterChipData {
  const ExpenseFilterChipData({
    required this.id,
    required this.label,
    required this.type,
  });

  final String id;
  final String label;
  final ExpenseFilterChipType type;
}
