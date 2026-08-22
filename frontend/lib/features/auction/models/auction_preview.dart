import 'package:frontend/shared/network/api_config.dart';

import 'auction_status.dart';

class AuctionPreview {
  const AuctionPreview({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.status,
    required this.remainingTime,
    required this.currentPrice,
    required this.bidCount,
    this.favoriteCount = 0,
    this.thumbnailUrl,
  });

  final int id;
  final String title;
  final String categoryName;
  final AuctionStatus status;
  final Duration remainingTime;
  final String currentPrice;
  final int bidCount;
  final int favoriteCount;
  final String? thumbnailUrl;

  String get remainingTimeLabel {
    if (status == AuctionStatus.completed || remainingTime <= Duration.zero) {
      return '0분 0초 남음';
    }

    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes.remainder(60);

    if (hours >= 1) {
      return '$hours시간 $minutes분 남음';
    }

    final seconds = remainingTime.inSeconds.remainder(60);
    return '$minutes분 $seconds초 남음';
  }

  factory AuctionPreview.fromJson(Map<String, dynamic> json) {
    final status = AuctionStatus.fromApiValue(json['status'] as String);
    final endsAt = DateTime.parse(json['ends_at'] as String);
    final startsAt = DateTime.parse(json['starts_at'] as String);
    final reference = status == AuctionStatus.waiting ? startsAt : endsAt;
    final remaining = reference.difference(DateTime.now());
    final thumbnailPath = json['thumbnail_url'] as String?;

    return AuctionPreview(
      id: json['id'] as int,
      title: json['title'] as String,
      categoryName: json['category_name'] as String,
      status: status,
      remainingTime: remaining.isNegative ? Duration.zero : remaining,
      currentPrice: '현재 ${_formatPrice(json['current_price'] as int)}',
      bidCount: json['bid_count'] as int,
      thumbnailUrl: thumbnailPath == null
          ? null
          : '${ApiConfig.mediaBaseUrl}$thumbnailPath',
    );
  }
}

const mockAuctions = [
  AuctionPreview(
    id: 1,
    title: '라이카 M6 클래식 필름 카메라',
    categoryName: '디지털기기',
    status: AuctionStatus.active,
    remainingTime: Duration(hours: 2, minutes: 14, seconds: 36),
    currentPrice: '현재 1,280,000원',
    bidCount: 4,
    favoriteCount: 18,
  ),
];

String _formatPrice(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  buffer.write('원');
  return buffer.toString();
}
