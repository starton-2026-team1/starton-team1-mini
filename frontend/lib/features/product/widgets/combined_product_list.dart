import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../auction/widgets/auction_list_item.dart';
import '../../auction/pages/auction_detail_page.dart';
import '../models/product_feed_item.dart';
import '../pages/product_detail_page.dart';
import 'product_list_item.dart';

class CombinedProductList extends StatelessWidget {
  const CombinedProductList({
    required this.items,
    required this.onRefresh,
    this.isLoadingMore = false,
    super.key,
  });

  final List<ProductFeedItem> items;
  final RefreshCallback onRefresh;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.borderSubtle),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = items[index];
          if (item.isAuction) {
            return AuctionListItem(
              auction: item.auction!,
              onEnded: onRefresh,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AuctionDetailPage(auctionId: item.auction!.id),
                  ),
                );
                // 상세에서 취소·거래 완료 후 돌아오면 카드 상태와 타이머 갱신
                await onRefresh();
              },
            );
          }

          return InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailPage(product: item.product!),
              ),
            ),
            child: ProductListItem(product: item.product!),
          );
        },
      ),
    );
  }
}
