import 'auction_preview.dart';

class AuctionPage {
  const AuctionPage({
    required this.items,
    required this.total,
    required this.nextOffset,
  });

  final List<AuctionPreview> items;
  final int total;
  final int nextOffset;

  factory AuctionPage.fromJson(
    Map<String, dynamic> json, {
    int fallbackOffset = 0,
  }) {
    final rawItems = json['items'] as List<dynamic>;
    return AuctionPage(
      items: auctionsWithEndedLast(
        rawItems.map(
          (item) => AuctionPreview.fromJson(item as Map<String, dynamic>),
        ),
      ),
      total: (json['total'] as num?)?.toInt() ?? rawItems.length,
      nextOffset:
          ((json['offset'] as num?)?.toInt() ?? fallbackOffset) +
          rawItems.length,
    );
  }

  bool get hasMore => nextOffset < total;

  AuctionPage append(AuctionPage page) {
    final auctionsById = {
      for (final auction in items) auction.id: auction,
      for (final auction in page.items) auction.id: auction,
    };
    return AuctionPage(
      items: auctionsWithEndedLast(auctionsById.values),
      total: page.total,
      nextOffset: page.nextOffset,
    );
  }
}
