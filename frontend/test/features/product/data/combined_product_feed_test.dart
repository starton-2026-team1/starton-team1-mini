import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/data/combined_product_feed.dart';
import 'package:frontend/shared/network/api_client.dart';

void main() {
  test('실제 상품과 경매 응답을 ID가 유지된 통합 목록으로 변환한다', () async {
    final api = CombinedProductFeedApi(_FakeApiClient());

    final feed = await api.load();

    expect(feed.products.single.id, 41);
    expect(feed.auctions, hasLength(2));
    expect(feed.items, hasLength(3));
    expect(feed.items.first.auction?.id, 12);
    expect(feed.items[1].product?.id, 41);
    expect(feed.items.last.auction?.id, 13);
  });
}

class _FakeApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    if (path == '/products') {
      return {
        'items': [
          {
            'id': 41,
            'title': '일반 상품',
            'description': '상품 설명',
            'created_at': DateTime.now().toIso8601String(),
            'fixed_price': {'price': 12000},
          },
        ],
      };
    }
    if (path == '/auctions') {
      return {
        'items': [
          {
            'id': 12,
            'title': '경매 상품',
            'category_name': '기타',
            'status': 'ACTIVE',
            'thumbnail_url': null,
            'current_price': 10000,
            'bid_count': 0,
            'starts_at': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
            'ends_at': DateTime.now()
                .add(const Duration(hours: 1))
                .toIso8601String(),
          },
          {
            'id': 13,
            'title': '종료 경매',
            'category_name': '기타',
            'status': 'NO_BIDS',
            'thumbnail_url': null,
            'current_price': 10000,
            'bid_count': 0,
            'starts_at': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
            'ends_at': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
          },
        ],
      };
    }
    throw ArgumentError.value(path, 'path');
  }
}
