import '../../auction/models/auction_preview.dart';
import '../models/product_feed_item.dart';
import '../models/product_preview.dart';

List<ProductFeedItem> buildCombinedProductFeed() {
  return [
    ...mockAuctions.map(ProductFeedItem.auction),
    ...mockProducts.map(ProductFeedItem.product),
  ];
}
