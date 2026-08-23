import '../../auction/models/auction_preview.dart';
import '../../../shared/network/api_client.dart';
import '../models/product_feed_item.dart';
import '../models/product_preview.dart';

class CombinedProductFeedData {
  const CombinedProductFeedData({
    required this.products,
    required this.auctions,
  });

  final List<ProductPreview> products;
  final List<AuctionPreview> auctions;

  List<ProductFeedItem> get items => [
    ...auctions.map(ProductFeedItem.auction),
    ...products.map(ProductFeedItem.product),
  ];
}

class CombinedProductFeedApi {
  CombinedProductFeedApi(this._client);

  final ApiClient _client;

  // 일반 상품과 경매를 동시에 조회해 메인 통합 목록을 구성한다.
  Future<CombinedProductFeedData> load() async {
    final responses = await Future.wait([
      _client.get('/products'),
      _client.get('/auctions'),
    ]);
    final productItems = responses[0]['items'] as List<dynamic>;
    final auctionItems = responses[1]['items'] as List<dynamic>;
    return CombinedProductFeedData(
      products: productItems
          .map((item) => ProductPreview.fromJson(item as Map<String, dynamic>))
          .toList(),
      auctions: auctionItems
          .map((item) => AuctionPreview.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
