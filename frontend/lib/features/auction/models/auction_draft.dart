class AuctionDraft {
  const AuctionDraft({
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.bidIncrement,
    required this.startsAt,
    required this.endsAt,
    required this.extensionCount,
    this.imagePaths = const [],
  });

  final String title;
  final String description;
  final String startingPrice;
  final String bidIncrement;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int extensionCount;
  final List<String> imagePaths;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startingPrice': startingPrice,
      'bidIncrement': bidIncrement,
      'startsAt': startsAt?.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
      'extensionCount': extensionCount,
      'imagePaths': imagePaths,
    };
  }

  factory AuctionDraft.fromJson(Map<String, dynamic> json) {
    return AuctionDraft(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startingPrice: json['startingPrice'] as String? ?? '',
      bidIncrement: json['bidIncrement'] as String? ?? '',
      startsAt: DateTime.tryParse(json['startsAt'] as String? ?? ''),
      endsAt: DateTime.tryParse(json['endsAt'] as String? ?? ''),
      extensionCount: json['extensionCount'] as int? ?? 0,
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}
