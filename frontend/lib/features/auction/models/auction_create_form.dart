class AuctionCreateForm {
  const AuctionCreateForm({
    required this.title,
    required this.description,
    required this.place,
    required this.startingPrice,
    required this.bidIncrement,
    required this.startsAt,
    required this.endsAt,
    required this.extensionCount,
    this.buyNowPrice,
    this.acceptPriceOffers = false,
  });

  final String title;
  final String description;
  final String place;
  final int startingPrice;
  final int bidIncrement;
  final DateTime startsAt;
  final DateTime endsAt;
  final int? buyNowPrice;
  final int extensionCount;
  final bool acceptPriceOffers;
}
