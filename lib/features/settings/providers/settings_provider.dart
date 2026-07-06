import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../expenses/models/expense_category.dart';
import '../../expenses/services/custom_category_service.dart';
import '../services/settings_firestore_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required this.categoryService,
    SettingsFirestoreService? settingsService,
  }) : _settingsService = settingsService ?? SettingsFirestoreService.memory();

  final CustomCategoryService categoryService;
  final SettingsFirestoreService _settingsService;

  static const _customCategoryColors = [
    AppColors.travel,
    AppColors.shopping,
    AppColors.entertainment,
    AppColors.health,
    AppColors.transport,
  ];

  static const _defaultMonthlyBudget = 0.0;
  static const _defaultCategoryBudgets = {
    'food': 4500.0,
    'groceries': 6500.0,
    'transport': 3000.0,
    'bills': 5000.0,
    'rent': 12000.0,
  };

  double _monthlyBudget = _defaultMonthlyBudget;
  final Map<String, double> _categoryBudgets = {..._defaultCategoryBudgets};
  List<ExpenseCategory> _customCategories = const [];
  String? _loadedUserId;
  bool _isLoadingCategories = false;
  bool _isLoadingBudget = false;
  String? _errorMessage;

  double get monthlyBudget => _monthlyBudget;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingBudget => _isLoadingBudget;
  String? get errorMessage => _errorMessage;

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

  Future<void> bindUser(String? uid) async {
    if (_loadedUserId == uid) {
      return;
    }

    _loadedUserId = uid;
    _customCategories = const [];
    _monthlyBudget = _defaultMonthlyBudget;
    _categoryBudgets
      ..clear()
      ..addAll(_defaultCategoryBudgets);
    _errorMessage = null;

    if (uid == null) {
      notifyListeners();
      return;
    }

    await Future.wait([loadCategories(uid), loadBudget(uid)]);
  }

  void setMonthlyBudget(double amount) {
    final normalizedAmount = _normalizeAmount(amount);
    if (_monthlyBudget == normalizedAmount) {
      return;
    }

    _monthlyBudget = normalizedAmount;
    _persistBudgetIfBound();
    notifyListeners();
  }

  void setCategoryBudget(String categoryId, double amount) {
    final normalizedAmount = _normalizeAmount(amount);
    if (normalizedAmount == 0) {
      if (_categoryBudgets.remove(categoryId) != null) {
        _persistBudgetIfBound();
        notifyListeners();
      }
      return;
    }

    if (_categoryBudgets[categoryId] == normalizedAmount) {
      return;
    }

    _categoryBudgets[categoryId] = normalizedAmount;
    _persistBudgetIfBound();
    notifyListeners();
  }

  void resetCategoryBudgets() {
    if (_categoryBudgets.isEmpty) {
      return;
    }

    _categoryBudgets.clear();
    _persistBudgetIfBound();
    notifyListeners();
  }

  void resetAllBudgets() {
    _monthlyBudget = _defaultMonthlyBudget;
    _categoryBudgets
      ..clear()
      ..addAll(_defaultCategoryBudgets);
    _persistBudgetIfBound();
    notifyListeners();
  }

  Future<void> loadCategories(String? uid) async {
    if (uid == null || _isLoadingCategories) {
      return;
    }

    _isLoadingCategories = true;
    notifyListeners();

    try {
      _customCategories = await categoryService.loadCustomCategories(uid);
      _loadedUserId = uid;
    } catch (_) {
      _errorMessage = 'Could not load categories.';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadBudget(String? uid) async {
    if (uid == null || _isLoadingBudget) {
      return;
    }

    _isLoadingBudget = true;
    notifyListeners();

    try {
      final budget = await _settingsService.loadBudget(uid);
      if (budget == null) {
        _errorMessage = null;
      } else {
        _monthlyBudget = budget.monthlyBudgetCents / 100;
        _categoryBudgets
          ..clear()
          ..addEntries(
            budget.categoryBudgetCents.entries.map(
              (entry) => MapEntry(entry.key, entry.value / 100),
            ),
          );
      }
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Could not load budgets.';
    } finally {
      _isLoadingBudget = false;
      notifyListeners();
    }
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
    if (uid == null) {
      return category;
    }

    try {
      await categoryService.saveCustomCategory(uid, category);
      _customCategories = [..._customCategories, category]
        ..sort((a, b) => a.label.compareTo(b.label));
      _loadedUserId = uid;
      _errorMessage = null;
      notifyListeners();
      return category;
    } catch (_) {
      _errorMessage = 'Could not save category.';
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteCustomCategory({
    required String? uid,
    required ExpenseCategory category,
  }) async {
    if (!category.isCustom) {
      return;
    }

    if (uid == null) {
      return;
    }

    await categoryService.deleteCustomCategory(uid, category.id);
    _customCategories = _customCategories
        .where((stored) => stored.id != category.id)
        .toList(growable: false);
    _categoryBudgets.remove(category.id);
    _persistBudgetIfBound();
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

  void _persistBudgetIfBound() {
    final uid = _loadedUserId;
    if (uid == null) {
      return;
    }
    _persistBudget(uid);
  }

  Future<void> _persistBudget(String uid) async {
    try {
      await _settingsService.saveBudget(
        uid,
        UserBudgetData(
          monthlyBudgetCents: (_monthlyBudget * 100).round(),
          categoryBudgetCents: _categoryBudgets.map(
            (key, value) => MapEntry(key, (value * 100).round()),
          ),
        ),
      );
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Could not save budgets.';
      notifyListeners();
    }
  }
}
