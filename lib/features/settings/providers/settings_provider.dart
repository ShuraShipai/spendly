import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../expenses/models/expense_category.dart';
import '../../expenses/services/custom_category_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required this.categoryService});

  final CustomCategoryService categoryService;

  static const _fallbackUserId = 'local';
  static const _customCategoryColors = [
    AppColors.travel,
    AppColors.shopping,
    AppColors.entertainment,
    AppColors.health,
    AppColors.transport,
  ];

  double _monthlyBudget = 25000;
  final Map<String, double> _categoryBudgets = {
    ExpenseCategory.food.id: 4500,
    ExpenseCategory.groceries.id: 6500,
    ExpenseCategory.transport.id: 3000,
    ExpenseCategory.bills.id: 5000,
    ExpenseCategory.rent.id: 12000,
  };
  List<ExpenseCategory> _customCategories = const [];
  String? _loadedUserId;
  bool _isLoadingCategories = false;

  double get monthlyBudget => _monthlyBudget;
  bool get isLoadingCategories => _isLoadingCategories;

  List<ExpenseCategory> get categories {
    return [
      ...ExpenseCategory.defaults,
      for (final category in _customCategories)
        if (!ExpenseCategory.defaults.any(
          (defaultCategory) =>
              defaultCategory.id == category.id ||
              defaultCategory.hasSameLabel(category.label),
        ))
          category,
    ];
  }

  double budgetForCategory(String categoryId) {
    return _categoryBudgets[categoryId] ?? 0;
  }

  void setMonthlyBudget(double amount) {
    final normalizedAmount = _normalizeAmount(amount);
    if (_monthlyBudget == normalizedAmount) {
      return;
    }

    _monthlyBudget = normalizedAmount;
    notifyListeners();
  }

  void setCategoryBudget(String categoryId, double amount) {
    final normalizedAmount = _normalizeAmount(amount);
    if (normalizedAmount == 0) {
      if (_categoryBudgets.remove(categoryId) != null) {
        notifyListeners();
      }
      return;
    }

    if (_categoryBudgets[categoryId] == normalizedAmount) {
      return;
    }

    _categoryBudgets[categoryId] = normalizedAmount;
    notifyListeners();
  }

  Future<void> loadCategories(String? uid) async {
    final userId = uid ?? _fallbackUserId;
    if (_loadedUserId == userId || _isLoadingCategories) {
      return;
    }

    _isLoadingCategories = true;
    notifyListeners();

    _customCategories = await categoryService.loadCustomCategories(userId);
    _loadedUserId = userId;
    _isLoadingCategories = false;
    notifyListeners();
  }

  Future<ExpenseCategory?> addCustomCategory({
    required String? uid,
    required String label,
  }) async {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      return null;
    }

    final existing = _findCategoryByLabel(trimmedLabel);
    if (existing != null) {
      return existing;
    }

    final category = ExpenseCategory.custom(
      label: trimmedLabel,
      color: _nextCustomCategoryColor,
    );
    final userId = uid ?? _fallbackUserId;

    await categoryService.saveCustomCategory(userId, category);
    _customCategories = [..._customCategories, category]
      ..sort((a, b) => a.label.compareTo(b.label));
    _loadedUserId = userId;
    notifyListeners();
    return category;
  }

  Future<void> deleteCustomCategory({
    required String? uid,
    required ExpenseCategory category,
  }) async {
    if (!category.isCustom) {
      return;
    }

    final userId = uid ?? _fallbackUserId;
    await categoryService.deleteCustomCategory(userId, category.id);
    _customCategories = _customCategories
        .where((stored) => stored.id != category.id)
        .toList(growable: false);
    _categoryBudgets.remove(category.id);
    notifyListeners();
  }

  ExpenseCategory? _findCategoryByLabel(String label) {
    for (final category in categories) {
      if (category.hasSameLabel(label)) {
        return category;
      }
    }
    return null;
  }

  double _normalizeAmount(double amount) {
    if (amount <= 0 || amount.isNaN || amount.isInfinite) {
      return 0;
    }

    return double.parse(amount.toStringAsFixed(2));
  }

  Color get _nextCustomCategoryColor {
    return _customCategoryColors[_customCategories.length %
        _customCategoryColors.length];
  }
}
