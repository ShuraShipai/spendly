import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.currencyCode = 'INR',
    this.note,
  }) : assert(amount > 0, 'Expense amount must be greater than zero.');

  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String currencyCode;
  final String? note;

  ExpenseEntry copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? currencyCode,
    Object? note = _unchanged,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      currencyCode: currencyCode ?? this.currencyCode,
      note: note == _unchanged ? this.note : note as String?,
    );
  }

  factory ExpenseEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final categoryId = data['categoryId'] as String? ?? 'uncategorized';
    final category = ExpenseCategory.byId(
      categoryId,
      labelSnapshot: data['categoryLabelSnapshot'] as String?,
      colorArgbSnapshot: data['categoryColorArgbSnapshot'] as int?,
      iconKeySnapshot: data['categoryIconKeySnapshot'] as String?,
    );
    final amountCents = data['amountCents'] as int? ?? 0;
    final occurredAt = data['occurredAt'];

    return ExpenseEntry(
      id: doc.id,
      amount: amountCents / 100,
      category: category,
      date: occurredAt is Timestamp ? occurredAt.toDate() : DateTime.now(),
      paymentMethod: PaymentMethod.fromId(data['paymentMethodId'] as String?),
      currencyCode: data['currencyCode'] as String? ?? 'INR',
      note: data['note'] as String?,
    );
  }

  Map<String, Object?> toFirestoreCreateMap() {
    return {
      ...toFirestoreUpdateMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'deletedAt': null,
    };
  }

  Map<String, Object?> toFirestoreUpdateMap() {
    return {
      'amountCents': (amount * 100).round(),
      'currencyCode': currencyCode,
      'categoryId': category.id,
      'categoryLabelSnapshot': category.label,
      'categoryColorArgbSnapshot': category.color.toARGB32(),
      'categoryIconKeySnapshot': category.iconKey,
      'paymentMethodId': paymentMethod.name,
      'occurredAt': Timestamp.fromDate(date),
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
