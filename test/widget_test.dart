import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:spendly/app/app_theme.dart';
import 'package:spendly/features/auth/constants/auth_constants.dart';
import 'package:spendly/features/auth/constants/auth_validators.dart';
import 'package:spendly/features/auth/models/password_strength.dart';
import 'package:spendly/features/auth/screens/welcome_screen.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/expenses/widgets/add_expense_flow_sheet.dart';
import 'package:spendly/features/home/widgets/email_verification_banner.dart';

void main() {
  test('validates auth form values', () {
    expect(AuthValidators.displayName(''), AuthConstants.nameRequired);
    expect(AuthValidators.displayName('Aanya Sharma'), isNull);

    expect(AuthValidators.email(''), AuthConstants.emailRequired);
    expect(AuthValidators.email('bad-email'), AuthConstants.emailInvalid);
    expect(AuthValidators.email('aanya@email.com'), isNull);

    expect(AuthValidators.password(''), AuthConstants.passwordRequired);
    expect(AuthValidators.password('short'), AuthConstants.passwordTooShort);
    expect(AuthValidators.password('long-enough'), isNull);

    expect(
      AuthValidators.confirmPassword('different', 'long-enough'),
      AuthConstants.passwordsDoNotMatch,
    );
    expect(
      AuthValidators.confirmPassword('long-enough', 'long-enough'),
      isNull,
    );
  });

  test('evaluates password strength', () {
    expect(
      PasswordStrengthEvaluator.evaluate('').level,
      PasswordStrengthLevel.empty,
    );
    expect(
      PasswordStrengthEvaluator.evaluate('short').level,
      PasswordStrengthLevel.weak,
    );
    expect(
      PasswordStrengthEvaluator.evaluate('longpassword').level,
      PasswordStrengthLevel.weak,
    );
    expect(
      PasswordStrengthEvaluator.evaluate('Longpassword1').level,
      PasswordStrengthLevel.good,
    );
    expect(
      PasswordStrengthEvaluator.evaluate('Longpassword1!').level,
      PasswordStrengthLevel.strong,
    );
  });

  testWidgets('renders the auth welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WelcomeScreen()),
    );

    expect(find.text('Money, made\nfriendly.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('renders the email verification banner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EmailVerificationBanner(
            email: 'aanya@email.com',
            isLoading: false,
            onResend: () {},
            onDismiss: () {},
          ),
        ),
      ),
    );

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('aanya@email.com'), findsOneWidget);
    expect(find.text('Resend email'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('moves from amount keypad to expense details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );

    expect(find.text('How much?'), findsOneWidget);
    expect(find.text('AMOUNT'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('UPI'), findsNothing);
    expect(find.text('Cash'), findsNothing);
  });

  testWidgets('requires payment method and supports custom categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    expect(find.text('New expense'), findsOneWidget);

    await tester.tap(find.text('PAY VIA'));
    await tester.pumpAndSettle();
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);

    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('Required'), findsNothing);

    await tester.tap(find.text('+ More'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Coffee');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
  });

  testWidgets('persists custom categories after the first saved expense', (
    WidgetTester tester,
  ) async {
    const userId = 'test-user';
    final categoryService = CustomCategoryService();

    Future<void> pumpSheet() {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Provider(
            create: (_) => categoryService,
            child: const Scaffold(body: AddExpenseFlowSheet(userId: userId)),
          ),
        ),
      );
    }

    await pumpSheet();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PAY VIA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ More'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Coffee');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    final savedCategories = await categoryService.loadCustomCategories(userId);
    expect(savedCategories, hasLength(1));
    expect(savedCategories.single.label, 'Coffee');

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpSheet();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
  });
}
