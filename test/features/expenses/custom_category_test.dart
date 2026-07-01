import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';

void main() {
  group('ExpenseCategory', () {
    test('uses a stable id for custom categories', () {
      final first = ExpenseCategory.custom(
        label: 'Coffee',
        color: AppColors.rent,
      );
      final second = ExpenseCategory.custom(
        label: 'coffee',
        color: AppColors.health,
      );

      expect(first.id, 'custom-coffee');
      expect(second.id, first.id);
      expect(first.isCustom, isTrue);
      expect(ExpenseCategory.food.isCustom, isFalse);
    });

    test('serializes and deserializes custom categories', () {
      final category = ExpenseCategory.custom(
        label: 'Team lunch',
        color: AppColors.travel,
      );

      final restored = ExpenseCategory.fromMap(category.toMap());

      expect(restored, category);
    });
  });

  group('CustomCategoryService', () {
    test('saves custom categories after first use and reloads them', () async {
      const userId = 'user-1';
      final service = CustomCategoryService();
      final coffee = ExpenseCategory.custom(
        label: 'Coffee',
        color: AppColors.rent,
      );

      expect(await service.loadCustomCategories(userId), isEmpty);

      await service.saveCustomCategory(userId, coffee);

      expect(await service.loadCustomCategories(userId), [coffee]);
    });

    test('updates an existing custom category with the same id', () async {
      const userId = 'user-1';
      final service = CustomCategoryService();
      final original = ExpenseCategory.custom(
        label: 'Coffee',
        color: AppColors.rent,
      );
      final updated = ExpenseCategory.custom(
        label: 'Coffee',
        color: AppColors.health,
      );

      await service.saveCustomCategory(userId, original);
      await service.saveCustomCategory(userId, updated);

      final loaded = await service.loadCustomCategories(userId);
      expect(loaded, hasLength(1));
      expect(loaded.single.color, AppColors.health);
    });
  });
}
