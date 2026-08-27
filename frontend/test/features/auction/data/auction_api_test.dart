import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/data/auction_api.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';

void main() {
  test('경매 다음 페이지를 중복 없이 추가한다', () async {
    final api = AuctionApi(_FakeApiClient(), AuthTokenStorage());

    final firstPage = await api.listAuctions();
    final nextPage = await api.listAuctions(offset: firstPage.nextOffset);
    final updatedPage = firstPage.append(nextPage);

    expect(updatedPage.items.map((auction) => auction.id), [1, 2]);
    expect(updatedPage.nextOffset, 3);
    expect(updatedPage.hasMore, isFalse);
  });
}

class _FakeApiClient extends ApiClient {
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    if (path == '/auctions?offset=0&limit=20') {
      return {
        'items': [_auctionJson(1)],
        'total': 3,
        'offset': 0,
        'limit': 20,
      };
    }
    if (path == '/auctions?offset=1&limit=20') {
      return {
        'items': [_auctionJson(1), _auctionJson(2)],
        'total': 3,
        'offset': 1,
        'limit': 20,
      };
    }
    throw ArgumentError.value(path, 'path');
  }
}

Map<String, dynamic> _auctionJson(int id) => {
  'id': id,
  'title': '경매 $id',
  'category_name': '기타',
  'status': 'ACTIVE',
  'thumbnail_url': null,
  'created_at': DateTime.now().toIso8601String(),
  'current_price': 10000,
  'bid_count': 0,
  'starts_at': DateTime.now()
      .subtract(const Duration(hours: 1))
      .toIso8601String(),
  'ends_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
};
