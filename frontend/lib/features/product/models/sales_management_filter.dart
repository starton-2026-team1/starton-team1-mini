enum SalesManagementFilter {
  auction('경매중'),
  selling('판매중'),
  completed('완료');

  const SalesManagementFilter(this.label);

  final String label;
}
