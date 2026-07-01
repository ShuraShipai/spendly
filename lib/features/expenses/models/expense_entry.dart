import 'expense_category.dart';
import 'payment_method.dart';

const _unchanged = Object();

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.note,
  });

  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? note;

  ExpenseEntry copyWith({
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    PaymentMethod? paymentMethod,
    Object? note = _unchanged,
  }) {
    return ExpenseEntry(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note == _unchanged ? this.note : note as String?,
    );
  }

  String get title => '${category.label} expense';

  String get displayTitle {
    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.isNotEmpty) {
      return trimmedNote;
    }

    return title;
  }

  String get subtitle {
    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.isNotEmpty) {
      return trimmedNote;
    }

    return category.label;
  }

  String get amountLabel {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  String get dateLabel {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    if (isToday) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
