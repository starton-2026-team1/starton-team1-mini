enum SalesManagementFilter {
  auction('경매중'),
  selling('판매중'),
  completed('완료'),
  bidding('입찰내역');

  const SalesManagementFilter(this.label);

  final String label;
}
