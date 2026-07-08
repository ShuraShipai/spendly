import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_category.dart';
import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/settings/widgets/budget_overview_card.dart';
import 'package:spendly/features/settings/widgets/category_budget_row.dart';

void main() {
  testWidgets('overall budget percent does not show 100 before full spend', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _WidgetHost(
        child: BudgetOverviewCard(
          budget: 1000,
          spent: 995,
          periodLabel: 'July',
        ),
      ),
    );

    expect(find.text('99%'), findsOneWidget);
    expect(find.text('100%'), findsNothing);
  });

  testWidgets('overall budget percent shows 100 at full spend', (tester) async {
    await tester.pumpWidget(
      const _WidgetHost(
        child: BudgetOverviewCard(
          budget: 1000,
          spent: 1000,
          periodLabel: 'July',
        ),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Approaching limit'), findsOneWidget);
    expect(find.text('Budget exceeded'), findsNothing);
    expect(_textColor(tester, 'Approaching limit'), AppColors.warning);
  });

  testWidgets('overall budget shows exceeded only after crossing limit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _WidgetHost(
        child: BudgetOverviewCard(
          budget: 1000,
          spent: 1001,
          periodLabel: 'July',
        ),
      ),
    );

    expect(find.text('Budget exceeded'), findsOneWidget);
    expect(_textColor(tester, 'Budget exceeded'), AppColors.danger);
  });

  testWidgets('category budget row stays approaching until limit is exceeded', (
    tester,
  ) async {
    await tester.pumpWidget(
      _WidgetHost(
        child: CategoryBudgetRow(
          category: ExpenseCategory.food,
          budget: 1000,
          spent: 896,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Approaching limit'), findsOneWidget);
    expect(find.text('Limit reached'), findsNothing);
    expect(_textColor(tester, 'Approaching limit'), AppColors.warning);
  });

  testWidgets('category budget row still approaches at exact budget', (
    tester,
  ) async {
    await tester.pumpWidget(
      _WidgetHost(
        child: CategoryBudgetRow(
          category: ExpenseCategory.food,
          budget: 1000,
          spent: 900,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Approaching limit'), findsOneWidget);
    expect(find.text('Limit reached'), findsNothing);
    expect(find.text('Budget exceeded'), findsNothing);
    expect(_textColor(tester, 'Approaching limit'), AppColors.warning);
  });

  testWidgets('category budget row shows exceeded only after crossing limit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _WidgetHost(
        child: CategoryBudgetRow(
          category: ExpenseCategory.food,
          budget: 1000,
          spent: 1001,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Budget exceeded'), findsOneWidget);
    expect(_textColor(tester, 'Budget exceeded'), AppColors.danger);
  });
}

Color? _textColor(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text)).style?.color;
}

class _WidgetHost extends StatelessWidget {
  const _WidgetHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
