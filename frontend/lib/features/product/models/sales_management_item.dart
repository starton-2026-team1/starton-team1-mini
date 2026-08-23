import 'sales_management_filter.dart';

class SalesManagementItem {
  const SalesManagementItem({
    required this.id,
    required this.filter,
    required this.title,
    required this.location,
    required this.timeLabel,
    required this.price,
    this.auctionId,
    this.imageUrl,
    this.viewCount = 0,
    this.chatCount = 0,
    this.auctionRemainingTime,
    this.bidCount = 0,
    this.auction = false,
  });

  factory SalesManagementItem.fromJson(
    Map<String, dynamic> json, {
    required String mediaBaseUrl,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final saleType = json['sale_type'] as String;
    final managementStatus = json['management_status'] as String;
    final createdAt = DateTime.parse(json['created_at'] as String).toLocal();
    final endsAtValue = json['ends_at'] as String?;
    final endsAt = endsAtValue == null
        ? null
        : DateTime.parse(endsAtValue).toLocal();
    final imagePath = json['thumbnail_url'] as String?;
    return SalesManagementItem(
      id: (json['id'] as num).toInt(),
      auctionId: (json['auction_id'] as num?)?.toInt(),
      filter: _filterFromApi(managementStatus),
      title: json['title'] as String,
      location: '전국',
      timeLabel: saleType == 'AUCTION'
          ? _auctionStatusLabel(json['auction_status'] as String)
          : _elapsedTimeLabel(createdAt, currentTime),
      price: (json['price'] as num).toInt(),
      imageUrl: _resolveImageUrl(imagePath, mediaBaseUrl),
      auctionRemainingTime: endsAt?.difference(currentTime),
      bidCount: (json['bid_count'] as num?)?.toInt() ?? 0,
      auction: saleType == 'AUCTION',
    );
  }

  final int id;
  final int? auctionId;
  final SalesManagementFilter filter;
  final String title;
  final String location;
  final String timeLabel;
  final int price;
  final String? imageUrl;
  final int viewCount;
  final int chatCount;
  final Duration? auctionRemainingTime;
  final int bidCount;
  final bool auction;

  bool get isAuction => auction || filter == SalesManagementFilter.auction;

  static SalesManagementFilter _filterFromApi(String value) => switch (value) {
    'AUCTION' => SalesManagementFilter.auction,
    'SELLING' => SalesManagementFilter.selling,
    'COMPLETED' => SalesManagementFilter.completed,
    _ => throw ArgumentError.value(value, 'management_status'),
  };

  static String _auctionStatusLabel(String value) => switch (value) {
    'WAITING' => '경매 시작 전',
    'ACTIVE' => '경매 진행 중',
    'COMPLETED' => '낙찰 완료',
    'NO_BIDS' => '유찰',
    'CANCELLED' => '경매 취소',
    'TRADE_COMPLETED' => '거래 완료',
    _ => throw ArgumentError.value(value, 'auction_status'),
  };

  static String? _resolveImageUrl(String? path, String mediaBaseUrl) {
    if (path == null || path.isEmpty) return null;
    if (Uri.tryParse(path)?.hasAbsolutePath == true &&
        path.startsWith('http')) {
      return path;
    }
    return '$mediaBaseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  static String _elapsedTimeLabel(DateTime createdAt, DateTime now) {
    final elapsed = now.difference(createdAt);
    if (elapsed.inMinutes < 1) return '방금 전';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}분 전';
    if (elapsed.inDays < 1) return '${elapsed.inHours}시간 전';
    return '${elapsed.inDays}일 전';
  }
}
