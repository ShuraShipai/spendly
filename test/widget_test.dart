import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/app/app_theme.dart';
import 'package:spendly/features/auth/constants/auth_constants.dart';
import 'package:spendly/features/auth/constants/auth_validators.dart';
import 'package:spendly/features/auth/models/password_strength.dart';
import 'package:spendly/features/auth/screens/welcome_screen.dart';

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
}
