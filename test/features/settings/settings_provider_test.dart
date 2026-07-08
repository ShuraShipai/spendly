import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/settings/providers/settings_provider.dart';
import 'package:spendly/features/settings/services/settings_firestore_service.dart';

void main() {
  group('SettingsProvider', () {
    test('updates monthly and category budgets', () {
      final provider = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider
        ..setMonthlyBudget(12000)
        ..setCategoryBudget(ExpenseCategory.food.id, 3000)
        ..setCategoryBudget(ExpenseCategory.food.id, 0);

      expect(provider.monthlyBudget, 12000);
      expect(provider.budgetForCategory(ExpenseCategory.food.id), 0);
      expect(notifications, 3);
    });

    test('loads creates reuses and deletes custom categories', () async {
      final provider = SettingsProvider(
        categoryService: CustomCategoryService.memory(),
      );

      await provider.loadCategories('user-1');
      final gym = await provider.addCustomCategory(uid: 'user-1', label: 'Gym');
      final duplicate = await provider.addCustomCategory(
        uid: 'user-1',
        label: ' gym ',
      );

      expect(gym, isNotNull);
      expect(duplicate, gym);
      expect(
        provider.categories.where((category) => category.label == 'Gym'),
        hasLength(1),
      );

      provider.setCategoryBudget(gym!.id, 900);
      await provider.deleteCustomCategory(uid: 'user-1', category: gym);

      expect(provider.categories.contains(gym), isFalse);
      expect(provider.budgetForCategory(gym.id), 0);
    });

    test('ignores stale category and budget loads after user switch', () async {
      final categoryService = _FakeCustomCategoryService();
      final settingsService = _FakeSettingsFirestoreService();
      final provider = SettingsProvider(
        categoryService: categoryService,
        settingsService: settingsService,
      );

      final user1Bind = provider.bindUser('user-1');
      await Future<void>.delayed(Duration.zero);

      final user2Bind = provider.bindUser('user-2');
      await Future<void>.delayed(Duration.zero);

      final user2Category = _customCategory('custom-user-2', 'User 2');
      categoryService.completeLoad('user-2', [user2Category]);
      settingsService.completeBudgetLoad(
        'user-2',
        const UserBudgetData(
          monthlyBudgetCents: 20000,
          categoryBudgetCents: {'food': 12300},
        ),
      );
      await user2Bind;

      final user1Category = _customCategory('custom-user-1', 'User 1');
      categoryService.completeLoad('user-1', [user1Category]);
      settingsService.completeBudgetLoad(
        'user-1',
        const UserBudgetData(
          monthlyBudgetCents: 10000,
          categoryBudgetCents: {'food': 99900},
        ),
      );
      await user1Bind;

      expect(provider.categories, contains(user2Category));
      expect(provider.categories, isNot(contains(user1Category)));
      expect(provider.monthlyBudget, 200);
      expect(provider.budgetForCategory('food'), 123);
    });

    test('serializes budget saves and ignores stale save errors', () async {
      final settingsService = _FakeSettingsFirestoreService(
        completeBudgetLoadsImmediately: true,
      );
      final provider = SettingsProvider(
        categoryService: _ImmediateCustomCategoryService(),
        settingsService: settingsService,
      );

      await provider.bindUser('user-1');

      provider
        ..setMonthlyBudget(100)
        ..setMonthlyBudget(200);

      expect(settingsService.startedBudgetSaves, hasLength(1));
      expect(
        settingsService.startedBudgetSaves.single.monthlyBudgetCents,
        10000,
      );

      settingsService.completeSave(
        0,
        error: Exception('stale write failed after a newer edit'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(provider.errorMessage, isNull);
      expect(settingsService.startedBudgetSaves, hasLength(2));
      expect(settingsService.startedBudgetSaves.last.monthlyBudgetCents, 20000);

      settingsService.completeSave(1);
      await Future<void>.delayed(Duration.zero);

      expect(provider.errorMessage, isNull);
      expect(
        settingsService.persistedBudgets['user-1']?.monthlyBudgetCents,
        20000,
      );
    });
  });
}

ExpenseCategory _customCategory(String id, String label) {
  return ExpenseCategory(
    id: id,
    label: label,
    color: const Color(0xff009688),
    icon: Icons.category_rounded,
  );
}

class _ImmediateCustomCategoryService extends CustomCategoryService {
  _ImmediateCustomCategoryService() : super.memory();

  @override
  Future<List<ExpenseCategory>> loadCustomCategories(String uid) async {
    return const [];
  }
}

class _FakeCustomCategoryService extends CustomCategoryService {
  _FakeCustomCategoryService() : super.memory();

  final _loadCompleters = <String, Completer<List<ExpenseCategory>>>{};

  @override
  Future<List<ExpenseCategory>> loadCustomCategories(String uid) {
    return _loadCompleters
        .putIfAbsent(uid, () => Completer<List<ExpenseCategory>>())
        .future;
  }

  void completeLoad(String uid, List<ExpenseCategory> categories) {
    _loadCompleters[uid]!.complete(categories);
  }
}

class _FakeSettingsFirestoreService extends SettingsFirestoreService {
  _FakeSettingsFirestoreService({this.completeBudgetLoadsImmediately = false})
    : super.memory();

  final bool completeBudgetLoadsImmediately;
  final _budgetLoadCompleters = <String, Completer<UserBudgetData?>>{};
  final _budgetSaveCompleters = <Completer<void>>[];
  final startedBudgetSaves = <UserBudgetData>[];
  final persistedBudgets = <String, UserBudgetData>{};

  @override
  Future<UserBudgetData?> loadBudget(String uid) {
    if (completeBudgetLoadsImmediately) {
      return Future<UserBudgetData?>.value();
    }

    return _budgetLoadCompleters
        .putIfAbsent(uid, () => Completer<UserBudgetData?>())
        .future;
  }

  void completeBudgetLoad(String uid, UserBudgetData? budget) {
    _budgetLoadCompleters[uid]!.complete(budget);
  }

  @override
  Future<void> saveBudget(String uid, UserBudgetData budget) async {
    final completer = Completer<void>();
    _budgetSaveCompleters.add(completer);
    startedBudgetSaves.add(budget);
    await completer.future;
    persistedBudgets[uid] = budget;
  }

  void completeSave(int index, {Object? error}) {
    if (error == null) {
      _budgetSaveCompleters[index].complete();
    } else {
      _budgetSaveCompleters[index].completeError(error);
    }
  }
}
