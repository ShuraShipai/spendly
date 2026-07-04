import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/settings/providers/settings_provider.dart';

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
  });
}
