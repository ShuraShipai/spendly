import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String id;
  final String label;
  final Color color;
  final IconData icon;

  static const food = ExpenseCategory(
    id: 'food',
    label: 'Food',
    color: AppColors.food,
    icon: Icons.restaurant_rounded,
  );
  static const groceries = ExpenseCategory(
    id: 'groceries',
    label: 'Groceries',
    color: AppColors.groceries,
    icon: Icons.shopping_basket_rounded,
  );
  static const transport = ExpenseCategory(
    id: 'transport',
    label: 'Transport',
    color: AppColors.transport,
    icon: Icons.directions_car_rounded,
  );
  static const shopping = ExpenseCategory(
    id: 'shopping',
    label: 'Shopping',
    color: AppColors.shopping,
    icon: Icons.shopping_bag_rounded,
  );
  static const bills = ExpenseCategory(
    id: 'bills',
    label: 'Bills',
    color: AppColors.bills,
    icon: Icons.receipt_long_rounded,
  );
  static const rent = ExpenseCategory(
    id: 'rent',
    label: 'Rent',
    color: AppColors.rent,
    icon: Icons.home_rounded,
  );
  static const health = ExpenseCategory(
    id: 'health',
    label: 'Health',
    color: AppColors.health,
    icon: Icons.favorite_rounded,
  );
  static const fun = ExpenseCategory(
    id: 'fun',
    label: 'Fun',
    color: AppColors.entertainment,
    icon: Icons.play_arrow_rounded,
  );
  static const travel = ExpenseCategory(
    id: 'travel',
    label: 'Travel',
    color: AppColors.travel,
    icon: Icons.near_me_rounded,
  );

  static const quickDefaults = [food, groceries, transport];
  static const defaults = [
    food,
    groceries,
    transport,
    shopping,
    bills,
    rent,
    health,
    fun,
    travel,
  ];

  static ExpenseCategory byId(
    String id, {
    String? labelSnapshot,
    int? colorArgbSnapshot,
  }) {
    for (final category in defaults) {
      if (category.id == id) {
        return category;
      }
    }

    return ExpenseCategory(
      id: id,
      label: labelSnapshot == null || labelSnapshot.isEmpty
          ? id
          : labelSnapshot,
      color: Color(colorArgbSnapshot ?? AppColors.mint.toARGB32()),
      icon: Icons.sell_rounded,
    );
  }

  bool get isCustom => !defaults.any((category) => category.id == id);

  bool hasSameLabel(String otherLabel) {
    return normalizedLabel(label) == normalizedLabel(otherLabel);
  }

  static String normalizedLabel(String label) {
    return label.trim().toLowerCase();
  }

  static String customIdFor(String label) {
    final slug = label
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return 'custom-${slug.isEmpty ? 'category' : slug}';
  }

  factory ExpenseCategory.custom({
    required String label,
    required Color color,
  }) {
    final trimmedLabel = label.trim();

    return ExpenseCategory(
      id: customIdFor(trimmedLabel),
      label: trimmedLabel,
      color: color,
      icon: Icons.sell_rounded,
    );
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as String,
      label: map['label'] as String,
      color: Color(map['color'] as int),
      icon: Icons.sell_rounded,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'label': label,
      'color': color.toARGB32(),
      'colorArgb': color.toARGB32(),
      'iconKey': isCustom ? 'sell' : id,
      'isSystem': !isCustom,
      'isQuick': quickDefaults.any((category) => category.id == id),
      'isArchived': false,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
