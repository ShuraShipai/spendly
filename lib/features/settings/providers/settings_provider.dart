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
  String? _boundUserId;
  bool _isLoadingCategories = false;
  bool _isLoadingBudget = false;
  String? _errorMessage;
  int _categoryLoadVersion = 0;
  int _budgetLoadVersion = 0;
  int _budgetSaveVersion = 0;
  _PendingBudgetSave? _pendingBudgetSave;
  Future<void>? _budgetSaveTask;

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
    if (_boundUserId == uid) {
      return;
    }

    _boundUserId = uid;
    _categoryLoadVersion++;
    _budgetLoadVersion++;
    _resetUserState();
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
    if (uid == null) {
      return;
    }

    _bindUserForExplicitLoad(uid);
    final loadVersion = ++_categoryLoadVersion;
    _isLoadingCategories = true;
    notifyListeners();

    try {
      final categories = await categoryService.loadCustomCategories(uid);
      if (!_isCurrentCategoryLoad(uid, loadVersion)) {
        return;
      }
      _customCategories = categories;
      _boundUserId = uid;
    } catch (_) {
      if (_isCurrentCategoryLoad(uid, loadVersion)) {
        _errorMessage = 'Could not load categories.';
      }
    } finally {
      if (_isCurrentCategoryLoad(uid, loadVersion)) {
        _isLoadingCategories = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadBudget(String? uid) async {
    if (uid == null) {
      return;
    }

    _bindUserForExplicitLoad(uid);
    final loadVersion = ++_budgetLoadVersion;
    _isLoadingBudget = true;
    notifyListeners();

    try {
      final budget = await _settingsService.loadBudget(uid);
      if (!_isCurrentBudgetLoad(uid, loadVersion)) {
        return;
      }
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
      if (_isCurrentBudgetLoad(uid, loadVersion)) {
        _errorMessage = 'Could not load budgets.';
      }
    } finally {
      if (_isCurrentBudgetLoad(uid, loadVersion)) {
        _isLoadingBudget = false;
        notifyListeners();
      }
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
      existingCategories: categories,
    );
    if (uid == null) {
      return category;
    }

    try {
      await categoryService.saveCustomCategory(uid, category);
      _customCategories = [..._customCategories, category]
        ..sort((a, b) => a.label.compareTo(b.label));
      _boundUserId = uid;
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
    final uid = _boundUserId;
    if (uid == null) {
      return;
    }
    _queueBudgetSave(uid, _currentBudgetData);
  }

  UserBudgetData get _currentBudgetData {
    return UserBudgetData(
      monthlyBudgetCents: (_monthlyBudget * 100).round(),
      categoryBudgetCents: _categoryBudgets.map(
        (key, value) => MapEntry(key, (value * 100).round()),
      ),
    );
  }

  void _queueBudgetSave(String uid, UserBudgetData budget) {
    _pendingBudgetSave = _PendingBudgetSave(
      uid: uid,
      budget: budget,
      version: ++_budgetSaveVersion,
    );
    _budgetSaveTask ??= _drainBudgetSaves();
  }

  Future<void> _drainBudgetSaves() async {
    while (_pendingBudgetSave != null) {
      final save = _pendingBudgetSave!;
      _pendingBudgetSave = null;

      try {
        await _settingsService.saveBudget(save.uid, save.budget);
        if (_isCurrentBudgetSave(save)) {
          _errorMessage = null;
        }
      } catch (_) {
        if (_isCurrentBudgetSave(save)) {
          _errorMessage = 'Could not save budgets.';
          notifyListeners();
        }
      }
    }
    _budgetSaveTask = null;
    if (_pendingBudgetSave != null) {
      _budgetSaveTask = _drainBudgetSaves();
    }
  }

  bool _isCurrentCategoryLoad(String uid, int version) {
    return _boundUserId == uid && _categoryLoadVersion == version;
  }

  bool _isCurrentBudgetLoad(String uid, int version) {
    return _boundUserId == uid && _budgetLoadVersion == version;
  }

  bool _isCurrentBudgetSave(_PendingBudgetSave save) {
    return _boundUserId == save.uid && _budgetSaveVersion == save.version;
  }

  void _bindUserForExplicitLoad(String uid) {
    if (_boundUserId == uid) {
      return;
    }

    _boundUserId = uid;
    _categoryLoadVersion++;
    _budgetLoadVersion++;
    _resetUserState();
    _errorMessage = null;
  }

  void _resetUserState() {
    _customCategories = const [];
    _monthlyBudget = _defaultMonthlyBudget;
    _categoryBudgets
      ..clear()
      ..addAll(_defaultCategoryBudgets);
  }
}

class _PendingBudgetSave {
  const _PendingBudgetSave({
    required this.uid,
    required this.budget,
    required this.version,
  });

  final String uid;
  final UserBudgetData budget;
  final int version;
}
