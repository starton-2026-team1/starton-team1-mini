import '../../auction/models/auction_preview.dart';
import 'product_preview.dart';

class ProductFeedItem {
  const ProductFeedItem.product(ProductPreview value)
    : product = value,
      auction = null;

  const ProductFeedItem.auction(AuctionPreview value)
    : product = null,
      auction = value;

  final ProductPreview? product;
  final AuctionPreview? auction;

  bool get isAuction => auction != null;

  DateTime get createdAt =>
      product?.createdAt ??
      auction?.createdAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
