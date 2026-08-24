import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/models/sales_management_filter.dart';
import 'package:frontend/features/product/models/sales_management_item.dart';

void main() {
  test('경매 판매관리 응답을 화면 모델로 변환한다', () {
    final now = DateTime(2026, 8, 23, 12);
    final item = SalesManagementItem.fromJson(
      {
        'id': 10,
        'auction_id': 7,
        'sale_type': 'AUCTION',
        'title': '아이패드',
        'description': '깨끗하게 사용했습니다.',
        'product_status': 'ACTIVE',
        'management_status': 'AUCTION',
        'auction_status': 'ACTIVE',
        'thumbnail_url': '/uploads/ipad.jpg',
        'price': 140000,
        'bid_count': 3,
        'starts_at': '2026-08-23T11:00:00',
        'ends_at': '2026-08-23T13:00:00',
        'created_at': '2026-08-23T10:00:00',
      },
      mediaBaseUrl: 'http://127.0.0.1:8000',
      now: now,
    );

    expect(item.filter, SalesManagementFilter.auction);
    expect(item.auctionId, 7);
    expect(item.price, 140000);
    expect(item.description, '깨끗하게 사용했습니다.');
    expect(item.bidCount, 3);
    expect(item.auctionRemainingTime, const Duration(hours: 1));
    expect(item.imageUrl, 'http://127.0.0.1:8000/uploads/ipad.jpg');
  });

  test('완료된 일반 판매 응답을 완료 필터로 변환한다', () {
    final item = SalesManagementItem.fromJson(
      {
        'id': 11,
        'auction_id': null,
        'sale_type': 'FIXED_PRICE',
        'title': '자전거',
        'description': '상태가 좋아요.',
        'product_status': 'SOLD',
        'management_status': 'COMPLETED',
        'auction_status': null,
        'thumbnail_url': null,
        'price': 30000,
        'bid_count': 0,
        'starts_at': null,
        'ends_at': null,
        'created_at': '2026-08-22T12:00:00',
      },
      mediaBaseUrl: 'http://127.0.0.1:8000',
      now: DateTime(2026, 8, 23, 12),
    );

    expect(item.filter, SalesManagementFilter.completed);
    expect(item.isAuction, isFalse);
    expect(item.timeLabel, '1일 전');
  });
}
