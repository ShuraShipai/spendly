import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:spendly/app/providers/app_state_provider.dart';
import 'package:spendly/app/app_theme.dart';
import 'package:spendly/features/auth/constants/auth_constants.dart';
import 'package:spendly/features/auth/constants/auth_validators.dart';
import 'package:spendly/features/auth/models/password_strength.dart';
import 'package:spendly/features/auth/screens/welcome_screen.dart';
import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/features/expenses/models/expense_entry.dart';
import 'package:spendly/features/expenses/models/payment_method.dart';
import 'package:spendly/features/expenses/providers/expense_provider.dart';
import 'package:spendly/features/expenses/services/custom_category_service.dart';
import 'package:spendly/features/expenses/screens/expense_list_screen.dart';
import 'package:spendly/features/expenses/widgets/add_expense_flow_sheet.dart';
import 'package:spendly/features/home/widgets/email_verification_banner.dart';
import 'package:spendly/features/home/widgets/recent_expenses_list.dart';
import 'package:spendly/features/reports/providers/reports_provider.dart';
import 'package:spendly/features/reports/screens/reports_screen.dart';
import 'package:spendly/features/settings/widgets/settings_body.dart';

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

  testWidgets('moves from expense details to amount keypad and back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('AMOUNT'), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('UPI'), findsNothing);
    expect(find.text('Cash'), findsNothing);

    await tester.tap(find.text('₹0'));
    await tester.pumpAndSettle();

    expect(find.text('How much?'), findsOneWidget);
    expect(find.text('FOOD'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);
  });

  testWidgets('keeps the note field visible above the keyboard', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 700);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );
    await tester.pumpAndSettle();

    final noteField = find.byType(TextField).last;
    await tester.tap(noteField);
    await tester.pump();

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    final noteRect = tester.getRect(noteField);
    final saveRect = tester.getRect(find.text('Save expense'));

    expect(tester.takeException(), isNull);
    expect(noteRect.bottom, lessThanOrEqualTo(saveRect.top));
    expect(saveRect.bottom, lessThanOrEqualTo(700));
  });

  testWidgets('renders every supplied recent expense', (
    WidgetTester tester,
  ) async {
    final expenses = [
      for (var index = 1; index <= 4; index++)
        ExpenseEntry(
          id: 'expense-$index',
          amount: index * 100,
          category: ExpenseCategory.food,
          date: DateTime(2026, 7, index),
          paymentMethod: PaymentMethod.cash,
          note: 'Expense $index',
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: RecentExpensesList(expenses: expenses)),
      ),
    );

    expect(find.text('Expense 1'), findsOneWidget);
    expect(find.text('Expense 2'), findsOneWidget);
    expect(find.text('Expense 3'), findsOneWidget);
    expect(find.text('Expense 4'), findsOneWidget);
  });

  testWidgets('renders recent expense cards in light and dark themes', (
    WidgetTester tester,
  ) async {
    final expenses = [
      ExpenseEntry(
        id: 'coffee',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.cash,
        note: 'Coffee',
      ),
    ];

    Future<Color> cardColorFor(ThemeMode themeMode) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: themeMode == ThemeMode.dark ? AppTheme.dark : AppTheme.light,
            child: Scaffold(body: RecentExpensesList(expenses: expenses)),
          ),
        ),
      );

      final cardBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(RecentExpensesList),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final cardDecoration = cardBox.decoration as BoxDecoration;
      return cardDecoration.color!;
    }

    expect(
      await cardColorFor(ThemeMode.light),
      AppTheme.light.colorScheme.surface,
    );
    expect(
      await cardColorFor(ThemeMode.dark),
      AppTheme.dark.colorScheme.surface,
    );
  });

  testWidgets('reports export opens a monthly CSV preview', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 15);
    final expenses = [
      ExpenseEntry(
        id: 'current-month',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, 2),
        paymentMethod: PaymentMethod.cash,
        note: 'Current month',
      ),
      ExpenseEntry(
        id: 'previous-month',
        amount: 900,
        category: ExpenseCategory.rent,
        date: previousMonth,
        paymentMethod: PaymentMethod.card,
        note: 'Previous month',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Provider(
          create: (_) => ReportsProvider(expenses: expenses),
          child: const Scaffold(body: ReportsScreen()),
        ),
      ),
    );

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();

    final previewText = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data!;
    expect(previewText, contains('Current month'));
    expect(previewText, isNot(contains('Previous month')));
  });

  testWidgets('settings export action uses the full CSV', (
    WidgetTester tester,
  ) async {
    String? exportedCsv;
    final expenses = [
      ExpenseEntry(
        id: 'july-food',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.cash,
        note: 'July food',
      ),
      ExpenseEntry(
        id: 'june-rent',
        amount: 900,
        category: ExpenseCategory.rent,
        date: DateTime(2026, 6, 15),
        paymentMethod: PaymentMethod.card,
        note: 'June rent',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Provider(
          create: (_) => ReportsProvider(expenses: expenses),
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: SettingsBody(
                  user: null,
                  appState: AppStateProvider(),
                  isAuthLoading: false,
                  platformBrightness: Brightness.light,
                  onEditProfile: () {},
                  onOpenCategories: () {},
                  onOpenCategoryBudgets: () {},
                  onOpenNotifications: () {},
                  onCurrencySelected: (_) {},
                  onWeekStartSelected: (_) {},
                  onThemeModeChanged: (_) {},
                  onBudgetAlertsChanged: (_) {},
                  onExportData: () {
                    exportedCsv = context.read<ReportsProvider>().allCsv();
                  },
                  onSignOut: () {},
                  onDeleteAccount: () {},
                  onShowOptionSheet:
                      <T>({
                        required title,
                        required options,
                        required selectedValue,
                        required onSelected,
                      }) {},
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Export data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export data'));
    await tester.pump();

    expect(exportedCsv, contains('July food'));
    expect(exportedCsv, contains('June rent'));
  });

  testWidgets('adds quick amount chips to the current amount', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );

    await tester.tap(find.text('₹0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+₹500'));
    await tester.pump();
    await tester.tap(find.text('+₹500'));
    await tester.pump();

    final richTextValues = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((richText) => richText.text.toPlainText());
    expect(richTextValues, contains('₹1000'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );

    await tester.tap(find.text('₹0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+₹100'));
    await tester.pump();
    await tester.tap(find.text('+₹100'));
    await tester.pump();
    await tester.tap(find.text('+₹100'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();

    final updatedRichTextValues = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((richText) => richText.text.toPlainText());
    expect(updatedRichTextValues, contains('₹3005'));
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

    await tester.tap(find.text('₹0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+₹100'));
    await tester.pumpAndSettle();
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

    await tester.enterText(
      find.byType(TextField).last,
      'Monthly internet bill',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ More'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a category'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Coffee');
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Coffee'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('+ More'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('Nice one!'), findsOneWidget);
    expect(find.text('Coffee expense'), findsOneWidget);
    expect(find.text('Monthly internet bill · Today'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('clears applied expense filters when returning to expenses', (
    WidgetTester tester,
  ) async {
    final expenseProvider = ExpenseProvider();
    expenseProvider.addExpense(
      ExpenseEntry(
        id: 'coffee',
        amount: 120,
        category: ExpenseCategory.food,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.cash,
        note: 'Coffee',
      ),
    );
    expenseProvider.addExpense(
      ExpenseEntry(
        id: 'rent',
        amount: 2000,
        category: ExpenseCategory.rent,
        date: DateTime(2026, 7, 2),
        paymentMethod: PaymentMethod.card,
        note: 'Rent',
      ),
    );

    var resetToken = 0;

    Future<void> pumpExpenses() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: expenseProvider,
              child: ExpenseListScreen(temporaryStateResetToken: resetToken),
            ),
          ),
        ),
      );
    }

    await pumpExpenses();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();

    expect(find.text('FILTERS'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Rent'), findsNothing);

    resetToken += 1;
    await pumpExpenses();
    await tester.pumpAndSettle();

    expect(find.text('FILTERS'), findsNothing);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('shows saved expense page without overflow on small screens', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 620);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AddExpenseFlowSheet()),
      ),
    );

    await tester.tap(find.text('₹0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+₹100'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PAY VIA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nice one!'), findsOneWidget);
    expect(
      find.text('Your expense is saved.\nYour dashboard is live.'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('keeps custom categories in memory for the current sheet', (
    WidgetTester tester,
  ) async {
    const userId = 'test-user';
    final categoryService = CustomCategoryService.memory();
    final expenseProvider = ExpenseProvider();

    Future<void> pumpSheet() {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MultiProvider(
            providers: [
              Provider(create: (_) => categoryService),
              ChangeNotifierProvider.value(value: expenseProvider),
            ],
            child: const Scaffold(body: AddExpenseFlowSheet(userId: userId)),
          ),
        ),
      );
    }

    await pumpSheet();
    await tester.tap(find.text('₹0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+₹100'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PAY VIA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ More'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Coffee');
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Coffee'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save expense'));
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('Nice one!'), findsOneWidget);
    expect(expenseProvider.expenses, hasLength(1));

    final savedCategories = await categoryService.loadCustomCategories(userId);
    expect(
      savedCategories.map((category) => category.label),
      contains('Coffee'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpSheet();
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ More'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Coffee');
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(GridView), matching: find.text('Coffee')),
      findsOneWidget,
    );
  });
}
