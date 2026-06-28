import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/app/spendly_app.dart';

void main() {
  testWidgets('renders the auth welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendlyApp());

    expect(find.text('Money, made\nfriendly.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}
