class AuctionDraft {
  const AuctionDraft({
    required this.title,
    required this.description,
    required this.place,
    required this.startingPrice,
    required this.bidIncrement,
    required this.buyNowPrice,
    required this.startsAt,
    required this.endsAt,
    required this.extensionCount,
    required this.acceptPriceOffers,
    this.imagePaths = const [],
  });

  final String title;
  final String description;
  final String place;
  final String startingPrice;
  final String bidIncrement;
  final String buyNowPrice;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int extensionCount;
  final bool acceptPriceOffers;
  final List<String> imagePaths;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'place': place,
      'startingPrice': startingPrice,
      'bidIncrement': bidIncrement,
      'buyNowPrice': buyNowPrice,
      'startsAt': startsAt?.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
      'extensionCount': extensionCount,
      'acceptPriceOffers': acceptPriceOffers,
      'imagePaths': imagePaths,
    };
  }

  factory AuctionDraft.fromJson(Map<String, dynamic> json) {
    return AuctionDraft(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      place: json['place'] as String? ?? '',
      startingPrice: json['startingPrice'] as String? ?? '',
      bidIncrement: json['bidIncrement'] as String? ?? '',
      buyNowPrice: json['buyNowPrice'] as String? ?? '',
      startsAt: DateTime.tryParse(json['startsAt'] as String? ?? ''),
      endsAt: DateTime.tryParse(json['endsAt'] as String? ?? ''),
      extensionCount: json['extensionCount'] as int? ?? 0,
      acceptPriceOffers: json['acceptPriceOffers'] as bool? ?? false,
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}
