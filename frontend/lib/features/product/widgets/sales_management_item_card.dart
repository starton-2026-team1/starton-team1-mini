import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../models/sales_management_filter.dart';
import '../models/sales_management_item.dart';

class SalesManagementItemCard extends StatelessWidget {
  const SalesManagementItemCard({
    required this.item,
    this.onTap,
    this.onAction,
    this.onMore,
    super.key,
  });

  final SalesManagementItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final VoidCallback? onMore;

  String get _statusLabel {
    if (item.filter == SalesManagementFilter.bidding) {
      return item.timeLabel;
    }
    if (item.filter == SalesManagementFilter.completed && item.isAuction) {
      return '경매완료';
    }
    return switch (item.filter) {
      SalesManagementFilter.auction => '경매중',
      SalesManagementFilter.selling => '판매중',
      SalesManagementFilter.completed => '거래완료',
      SalesManagementFilter.bidding => item.timeLabel,
    };
  }

  String get _actionLabel => switch (item.filter) {
    SalesManagementFilter.auction => '끌어올리기',
    SalesManagementFilter.selling => '끌어올리기',
    SalesManagementFilter.completed => '후기 보내기',
    SalesManagementFilter.bidding => '경매 상세 보기',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: item.filter == SalesManagementFilter.completed
                          ? AppColors.textSecondary
                          : AppColors.textStrong,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ItemImage(
                    imageUrl: item.imageUrl,
                    isAuction: item.isAuction,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 104,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.filter == SalesManagementFilter.bidding
                                ? '${item.location} · 경매 참여'
                                : '${item.location} · ${item.timeLabel}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            switch (item.filter) {
                              SalesManagementFilter.auction =>
                                '현재가 ${_formatPrice(item.price)}원',
                              SalesManagementFilter.completed
                                  when item.isAuction =>
                                '최종 낙찰가 ${_formatPrice(item.price)}원',
                              SalesManagementFilter.bidding =>
                                '현재가 ${_formatPrice(item.price)}원 · '
                                    '내 입찰 ${_formatPrice(item.myHighestBid ?? 0)}원',
                              _ => '${_formatPrice(item.price)}원',
                            },
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (item.isAuction)
                            _AuctionSummary(item: item)
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: _ItemMetrics(item: item),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  disabledBackgroundColor: AppColors.surfaceMuted,
                  foregroundColor: AppColors.textStrong,
                  disabledForegroundColor: AppColors.textSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  item.filter == SalesManagementFilter.completed
                      ? Icons.edit
                      : item.filter == SalesManagementFilter.bidding
                      ? Icons.arrow_forward
                      : Icons.vertical_align_top,
                  size: 19,
                ),
                label: Text(
                  _actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl, required this.isAuction});

  final String? imageUrl;
  final bool isAuction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 104,
        height: 104,
        child: imageUrl == null
            ? ColoredBox(
                color: AppColors.surfaceMuted,
                child: Icon(
                  isAuction ? Icons.gavel_outlined : Icons.image_outlined,
                  color: AppColors.textSecondary,
                  size: 34,
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}

class _ItemMetrics extends StatelessWidget {
  const _ItemMetrics({required this.item});

  final SalesManagementItem item;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.textDisabled, fontSize: 13);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.visibility_outlined,
          size: 16,
          color: AppColors.textDisabled,
        ),
        Text(' ${item.viewCount}', style: style),
        const SizedBox(width: 7),
        const Icon(Icons.chat_bubble, size: 15, color: AppColors.textDisabled),
        Text(' ${item.chatCount}', style: style),
      ],
    );
  }
}

class _AuctionSummary extends StatelessWidget {
  const _AuctionSummary({required this.item});

  final SalesManagementItem item;

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.filter == SalesManagementFilter.completed;
    return Row(
      children: [
        if (!isCompleted) ...[
          const Icon(Icons.timer_outlined, size: 16, color: AppColors.auction),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _remainingTimeLabel(item.auctionRemainingTime),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.auction,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ] else
          const Spacer(),
        const Icon(Icons.gavel, size: 15, color: AppColors.textDisabled),
        Text(
          ' ${item.bidCount}',
          style: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
        ),
      ],
    );
  }

  String _remainingTimeLabel(Duration? remainingTime) {
    if (remainingTime == null || remainingTime <= Duration.zero) {
      return '경매 종료';
    }

    final hours = remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = remainingTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remainingTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
