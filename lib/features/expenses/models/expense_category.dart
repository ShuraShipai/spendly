import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ExpenseCategory {
  food('Food', AppColors.food, Icons.restaurant_rounded),
  groceries('Groceries', AppColors.groceries, Icons.shopping_basket_rounded),
  transport('Transport', AppColors.transport, Icons.directions_car_rounded),
  shopping('Shopping', AppColors.shopping, Icons.shopping_bag_rounded);

  const ExpenseCategory(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}
