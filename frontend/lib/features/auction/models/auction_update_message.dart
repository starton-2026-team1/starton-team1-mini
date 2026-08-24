import 'package:frontend/features/auction/models/auction_detail.dart';

class AuctionUpdateMessage {
  const AuctionUpdateMessage({
    required this.currentPrice,
    required this.nextBidPrice,
    required this.endsAt,
    required this.remainingExtensionCount,
    required this.latestBid,
  });

  final int currentPrice;
  final int nextBidPrice;
  final DateTime endsAt;
  final int remainingExtensionCount;
  final AuctionBidPreview latestBid;

  factory AuctionUpdateMessage.fromJson(Map<String, dynamic> json) {
    return AuctionUpdateMessage(
      currentPrice: json['current_price'] as int,
      nextBidPrice: json['next_bid_price'] as int,
      endsAt: DateTime.parse(json['ends_at'] as String),
      remainingExtensionCount: json['remaining_extension_count'] as int,
      latestBid: AuctionBidPreview(
        bidderName: json['latest_bid']['bidder_name'] as String,
        amount: json['latest_bid']['amount'] as int,
        timeLabel: relativeTimeLabel(
          DateTime.parse(json['latest_bid']['created_at'] as String),
        ),
      ),
    );
  }
}
