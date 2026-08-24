import '../../auction/models/auction_preview.dart';
import '../../../shared/network/api_client.dart';
import '../models/product_feed_item.dart';
import '../models/product_preview.dart';

class CombinedProductFeedData {
  const CombinedProductFeedData({
    required this.products,
    required this.auctions,
    required this.productTotal,
    required this.nextProductOffset,
  });

  final List<ProductPreview> products;
  final List<AuctionPreview> auctions;
  final int productTotal;
  final int nextProductOffset;

  bool get hasMoreProducts => nextProductOffset < productTotal;

  CombinedProductFeedData appendProducts(ProductPageData page) {
    final productsById = {
      for (final product in products) product.id: product,
      for (final product in page.items) product.id: product,
    };
    return CombinedProductFeedData(
      products: productsById.values.toList(),
      auctions: auctions,
      productTotal: page.total,
      nextProductOffset: page.nextOffset,
    );
  }

  List<ProductFeedItem> get items {
    final runningAuctions = auctions.where((auction) => !auction.isEnded);
    final endedAuctions = auctions.where((auction) => auction.isEnded);
    return [
      ...runningAuctions.map(ProductFeedItem.auction),
      ...products.map(ProductFeedItem.product),
      // 종료·유찰·취소·거래 완료 경매를 메인 통합 목록 최하단에 배치
      ...endedAuctions.map(ProductFeedItem.auction),
    ];
  }
}

class ProductPageData {
  const ProductPageData({
    required this.items,
    required this.total,
    required this.nextOffset,
  });

  final List<ProductPreview> items;
  final int total;
  final int nextOffset;
}

class CombinedProductFeedApi {
  CombinedProductFeedApi(this._client);

  final ApiClient _client;

  // 일반 상품과 경매를 동시에 조회해 메인 통합 목록을 구성한다.
  Future<CombinedProductFeedData> load({int productLimit = 20}) async {
    final responses = await Future.wait([
      _client.get('/products?offset=0&limit=$productLimit'),
      _client.get('/auctions'),
    ]);
    final productPage = _parseProductPage(responses[0]);
    final auctionItems = responses[1]['items'] as List<dynamic>;
    return CombinedProductFeedData(
      products: productPage.items,
      auctions: auctionItems
          .map((item) => AuctionPreview.fromJson(item as Map<String, dynamic>))
          .toList(),
      productTotal: productPage.total,
      nextProductOffset: productPage.nextOffset,
    );
  }

  Future<ProductPageData> loadProducts({
    required int offset,
    int limit = 20,
  }) async {
    final response = await _client.get('/products?offset=$offset&limit=$limit');
    return _parseProductPage(response);
  }

  ProductPageData _parseProductPage(Map<String, dynamic> response) {
    final rawItems = response['items'] as List<dynamic>;
    final offset = (response['offset'] as num?)?.toInt() ?? 0;
    return ProductPageData(
      items: rawItems
          .map((item) => ProductPreview.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (response['total'] as num?)?.toInt() ?? rawItems.length,
      nextOffset: offset + rawItems.length,
    );
  }
}
