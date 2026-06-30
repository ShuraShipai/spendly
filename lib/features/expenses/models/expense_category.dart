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

  static const defaults = [food, groceries, transport, shopping];

  factory ExpenseCategory.custom({
    required String label,
    required Color color,
  }) {
    final trimmedLabel = label.trim();

    return ExpenseCategory(
      id: 'custom-${trimmedLabel.toLowerCase()}-${DateTime.now().microsecondsSinceEpoch}',
      label: trimmedLabel,
      color: color,
      icon: Icons.sell_rounded,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
