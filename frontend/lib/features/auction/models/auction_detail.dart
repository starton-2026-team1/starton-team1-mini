import 'package:frontend/shared/network/api_config.dart';

import 'auction_status.dart';

class AuctionBidPreview {
  const AuctionBidPreview({
    required this.bidderName,
    required this.amount,
    required this.timeLabel,
  });

  final String bidderName;
  final int amount;
  final String timeLabel;
}

class AuctionDetail {
  const AuctionDetail({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.sellerName,
    this.sellerId = 0,
    this.winnerName,
    required this.mannerTemperature,
    required this.startPrice,
    required this.currentPrice,
    required this.minimumBidUnit,
    required this.remainingTime,
    required this.description,
    required this.favoriteCount,
    required this.bids,
    this.status = AuctionStatus.active,
    this.imageUrls = const [],
  });

  final int id;
  final String title;
  final String category;
  final String location;
  final String sellerName;
  final int sellerId;
  final String? winnerName;
  final double mannerTemperature;
  final int startPrice;
  final int currentPrice;
  final int minimumBidUnit;
  final Duration remainingTime;
  final String description;
  final int favoriteCount;
  final List<AuctionBidPreview> bids;
  final AuctionStatus status;
  final List<String> imageUrls;

  int get imageCount => imageUrls.isEmpty ? 1 : imageUrls.length;

  int get nextBidPrice =>
      bids.isEmpty ? startPrice : currentPrice + minimumBidUnit;

  AuctionDetail copyWith({List<AuctionBidPreview>? bids, int? currentPrice}) {
    return AuctionDetail(
      id: id,
      title: title,
      category: category,
      location: location,
      sellerName: sellerName,
      sellerId: sellerId,
      winnerName: winnerName,
      mannerTemperature: mannerTemperature,
      startPrice: startPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      minimumBidUnit: minimumBidUnit,
      remainingTime: remainingTime,
      description: description,
      favoriteCount: favoriteCount,
      bids: bids ?? this.bids,
      status: status,
      imageUrls: imageUrls,
    );
  }

  factory AuctionDetail.fromJson(Map<String, dynamic> json) {
    final status = AuctionStatus.fromApiValue(json['status'] as String);
    final startsAt = DateTime.parse(json['starts_at'] as String);
    final endsAt = DateTime.parse(json['ends_at'] as String);
    final reference = status == AuctionStatus.waiting ? startsAt : endsAt;
    final remaining = reference.difference(DateTime.now());
    final images = json['image_urls'] as List<dynamic>;
    final bids = json['bids'] as List<dynamic>;

    return AuctionDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category_name'] as String,
      location: '',
      sellerName: json['seller_name'] as String,
      sellerId: json['seller_id'] as int,
      winnerName: json['winner_name'] as String?,
      mannerTemperature: 36.5,
      startPrice: json['start_price'] as int,
      currentPrice: json['current_price'] as int,
      minimumBidUnit: json['minimum_bid_unit'] as int,
      remainingTime: remaining.isNegative ? Duration.zero : remaining,
      description: json['description'] as String,
      favoriteCount: 0,
      bids: bids
          .map(
            (bid) => AuctionBidPreview(
              bidderName: bid['bidder_name'] as String,
              amount: bid['amount'] as int,
              timeLabel: relativeTimeLabel(
                DateTime.parse(bid['created_at'] as String),
              ),
            ),
          )
          .toList(),
      status: status,
      imageUrls: images
          .map((image) => _absoluteImageUrl(image as String))
          .toList(),
    );
  }
}

String relativeTimeLabel(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}

String _absoluteImageUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${ApiConfig.mediaBaseUrl}$path';
}
