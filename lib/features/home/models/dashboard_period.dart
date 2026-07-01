enum DashboardPeriod {
  today('Today', 'SPENT TODAY'),
  week('Week', 'SPENT THIS WEEK'),
  month('Month', 'SPENT THIS MONTH');

  const DashboardPeriod(this.label, this.totalLabel);

  final String label;
  final String totalLabel;
}
