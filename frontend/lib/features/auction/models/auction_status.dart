enum AuctionStatus {
  waiting('WAITING', '경매 대기중'),
  active('ACTIVE', '경매 진행중'),
  completed('COMPLETED', '경매 완료'),
  noBids('NO_BIDS', '유찰'),
  cancelled('CANCELLED', '경매 취소'),
  tradeCompleted('TRADE_COMPLETED', '거래 완료');

  const AuctionStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get canBid => this == AuctionStatus.active;

  bool get hasRunningTimer =>
      this == AuctionStatus.waiting || this == AuctionStatus.active;

  static AuctionStatus fromApiValue(String value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => throw ArgumentError.value(value, 'value', '알 수 없는 경매 상태'),
  );
}
