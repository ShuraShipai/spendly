import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/expenses/models/expense_list_query_state.dart';
import 'package:spendly/features/expenses/models/expense_sort_option.dart';

void main() {
  test('restores previous sort when search is toggled off', () {
    final queryState = ExpenseListQueryState()
      ..sortOption = ExpenseSortOption.oldest;

    queryState.toggleSearch();

    expect(queryState.isSearching, isTrue);
    expect(queryState.sortOption, ExpenseSortOption.highestAmount);

    queryState.toggleSearch();

    expect(queryState.isSearching, isFalse);
    expect(queryState.sortOption, ExpenseSortOption.oldest);
  });

  test('restores previous sort when search is reset', () {
    final queryState = ExpenseListQueryState()
      ..sortOption = ExpenseSortOption.lowestAmount;

    queryState.toggleSearch();
    queryState.reset();

    expect(queryState.isSearching, isFalse);
    expect(queryState.sortOption, ExpenseSortOption.lowestAmount);
  });
}
