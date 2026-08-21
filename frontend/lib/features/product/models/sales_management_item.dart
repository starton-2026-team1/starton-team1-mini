import 'sales_management_filter.dart';

class SalesManagementItem {
  const SalesManagementItem({
    required this.id,
    required this.filter,
    required this.title,
    required this.location,
    required this.timeLabel,
    required this.price,
    this.imageUrl,
    this.viewCount = 0,
    this.chatCount = 0,
    this.favoriteCount = 0,
    this.auctionRemainingTime,
    this.bidCount = 0,
    this.auction = false,
  });

  factory SalesManagementItem.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String;
    return SalesManagementItem(
      id: (json['id'] as num).toInt(),
      filter: status == 'SOLD'
          ? SalesManagementFilter.completed
          : SalesManagementFilter.selling,
      title: json['title'] as String,
      location: json['location'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? '',
      price: ((json['fixed_price'] as Map<String, dynamic>)['price'] as num)
          .toInt(),
      imageUrl: json['image_url'] as String?,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      chatCount: (json['chat_count'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favorite_count'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final SalesManagementFilter filter;
  final String title;
  final String location;
  final String timeLabel;
  final int price;
  final String? imageUrl;
  final int viewCount;
  final int chatCount;
  final int favoriteCount;
  final Duration? auctionRemainingTime;
  final int bidCount;
  final bool auction;

  bool get isAuction => auction || filter == SalesManagementFilter.auction;
}
