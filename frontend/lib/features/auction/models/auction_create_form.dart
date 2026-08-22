class AuctionCreateForm {
  const AuctionCreateForm({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.bidIncrement,
    required this.startsAt,
    required this.endsAt,
    required this.extensionCount,
    required this.imagePaths,
  });

  final int categoryId;
  final String title;
  final String description;
  final int startingPrice;
  final int bidIncrement;
  final DateTime startsAt;
  final DateTime endsAt;
  final int extensionCount;
  final List<String> imagePaths;
}
