enum TimeRange {
  days7(7, '7d'),
  days30(30, '30d'),
  days90(90, '90d');

  final int days;
  final String label;

  const TimeRange(this.days, this.label);
}