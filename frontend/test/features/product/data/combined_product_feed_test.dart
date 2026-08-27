import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/data/combined_product_feed.dart';
import 'package:frontend/shared/network/api_client.dart';

void main() {
  test('실제 상품과 경매 응답을 ID가 유지된 통합 목록으로 변환한다', () async {
    final api = CombinedProductFeedApi(_FakeApiClient());

    final feed = await api.load();

    expect(feed.products.single.id, 41);
    expect(feed.productTotal, 2);
    expect(feed.nextProductOffset, 1);
    expect(feed.hasMoreProducts, isTrue);
    expect(feed.auctions, hasLength(2));
    expect(feed.auctionTotal, 3);
    expect(feed.nextAuctionOffset, 2);
    expect(feed.hasMoreAuctions, isTrue);
    expect(feed.items, hasLength(3));
    expect(feed.items.first.auction?.id, 12);
    expect(feed.items[1].product?.id, 41);
    expect(feed.items.last.auction?.id, 13);
  });

  test('다음 경매 페이지를 전체 피드에 중복 없이 추가한다', () async {
    final api = CombinedProductFeedApi(_FakeApiClient());
    final feed = await api.load();

    final nextPage = await api.loadAuctions(offset: feed.nextAuctionOffset);
    final updated = feed.appendAuctions(nextPage);

    expect(updated.auctions.map((auction) => auction.id), [12, 14, 13]);
    expect(updated.nextAuctionOffset, 4);
    expect(updated.hasMoreAuctions, isFalse);
  });

  test('다음 일반 상품 페이지를 기존 목록에 중복 없이 추가한다', () async {
    final api = CombinedProductFeedApi(_FakeApiClient());
    final feed = await api.load();

    final nextPage = await api.loadProducts(offset: feed.nextProductOffset);
    final updated = feed.appendProducts(nextPage);

    expect(updated.products.map((product) => product.id), [41, 42]);
    expect(updated.nextProductOffset, 3);
    expect(updated.hasMoreProducts, isFalse);
  });
}

class _FakeApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    if (path == '/products?offset=0&limit=20') {
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
        'total': 2,
        'offset': 0,
        'limit': 20,
      };
    }
    if (path == '/products?offset=1&limit=20') {
      return {
        'items': [
          {
            'id': 41,
            'title': '중복 상품',
            'description': '중복 확인용',
            'created_at': DateTime.now().toIso8601String(),
            'fixed_price': {'price': 12000},
          },
          {
            'id': 42,
            'title': '다음 상품',
            'description': '다음 페이지 상품',
            'created_at': DateTime.now().toIso8601String(),
            'fixed_price': {'price': 15000},
          },
        ],
        'total': 3,
        'offset': 1,
        'limit': 20,
      };
    }
    if (path == '/auctions?offset=0&limit=20') {
      return {
        'items': [
          {
            'id': 12,
            'title': '경매 상품',
            'category_name': '기타',
            'status': 'ACTIVE',
            'thumbnail_url': null,
            'created_at': DateTime.now()
                .add(const Duration(minutes: 1))
                .toIso8601String(),
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
            'created_at': DateTime.now()
                .add(const Duration(minutes: 2))
                .toIso8601String(),
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
        'total': 3,
        'offset': 0,
        'limit': 20,
      };
    }
    if (path == '/auctions?offset=2&limit=20') {
      return {
        'items': [
          {
            'id': 12,
            'title': '중복 경매',
            'category_name': '기타',
            'status': 'ACTIVE',
            'thumbnail_url': null,
            'created_at': DateTime.now().toIso8601String(),
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
            'id': 14,
            'title': '다음 경매',
            'category_name': '기타',
            'status': 'ACTIVE',
            'thumbnail_url': null,
            'created_at': DateTime.now()
                .subtract(const Duration(minutes: 1))
                .toIso8601String(),
            'current_price': 15000,
            'bid_count': 1,
            'starts_at': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
            'ends_at': DateTime.now()
                .add(const Duration(hours: 2))
                .toIso8601String(),
          },
        ],
        'total': 4,
        'offset': 2,
        'limit': 20,
      };
    }
    throw ArgumentError.value(path, 'path');
  }
}
