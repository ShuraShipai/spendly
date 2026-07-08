import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app shell contracts', () {
    test('proxy provider fallbacks reuse registered dependencies', () {
      final appProviders = File(
        'lib/app/app_providers.dart',
      ).readAsStringSync();

      expect(
        appProviders,
        isNot(
          contains(
            'AppStateProvider(settingsService: SettingsFirestoreService())',
          ),
        ),
      );
      expect(
        appProviders,
        isNot(contains('ExpenseProvider(expenseService: ExpenseService())')),
      );
      expect(
        appProviders,
        isNot(contains('categoryService: CustomCategoryService()')),
      );
      expect(
        appProviders,
        isNot(contains('settingsService: SettingsFirestoreService()')),
      );
      expect(
        RegExp(
          r'localNotificationService:\s*context\s*'
          r'\.read<BudgetLocalNotificationService>\(\)',
        ).hasMatch(appProviders),
        isTrue,
      );
    });

    test('settings auth destructive actions reset navigation to AuthGate', () {
      final settingsScreen = File(
        'lib/features/settings/screens/settings_screen.dart',
      ).readAsStringSync();

      expect(
        RegExp(
          r'await authProvider\.logout\(\);[\s\S]*'
          r'pushNamedAndRemoveUntil\(AppRoutes\.authGate, \(_\) => false\)',
        ).hasMatch(settingsScreen),
        isTrue,
      );
      expect(
        RegExp(
          r'await authProvider\.deleteAccount\(\);[\s\S]*'
          r'pushNamedAndRemoveUntil\(AppRoutes\.authGate, \(_\) => false\)',
        ).hasMatch(settingsScreen),
        isTrue,
      );
    });

    test('Android manifest declares Android 13 notification permission', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    });
  });
}
