import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../auction/widgets/auction_list_item.dart';
import '../models/product_feed_item.dart';
import 'product_list_item.dart';

class CombinedProductList extends StatelessWidget {
  const CombinedProductList({required this.items, super.key});

  final List<ProductFeedItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.borderSubtle),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isAuction) {
          return AuctionListItem(auction: item.auction!);
        }

        return ProductListItem(product: item.product!);
      },
    );
  }
}
