enum ExpenseSortOption {
  newest('Newest first'),
  oldest('Oldest first'),
  highestAmount('Highest amount'),
  lowestAmount('Lowest amount');

  const ExpenseSortOption(this.label);

  final String label;
}
