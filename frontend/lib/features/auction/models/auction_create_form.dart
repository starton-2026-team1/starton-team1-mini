class AuctionCreateForm {
  const AuctionCreateForm({
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.bidIncrement,
    required this.startsAt,
    required this.endsAt,
    required this.extensionCount,
    required this.imagePaths,
    this.buyNowPrice,
  });

  final String title;
  final String description;
  final int startingPrice;
  final int bidIncrement;
  final DateTime startsAt;
  final DateTime endsAt;
  final int? buyNowPrice;
  final int extensionCount;
  final List<String> imagePaths;
}
