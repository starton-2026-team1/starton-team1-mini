import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../models/auction_preview.dart';

class AuctionListItem extends StatelessWidget {
  const AuctionListItem({required this.auction, super.key});

  final AuctionPreview auction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuctionImage(imageAsset: auction.imageAsset),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            auction.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${auction.location} · ${_statusLabel(auction.status)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _currentPriceLabel(auction.currentPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: _accentColor(auction.status),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${_remainingTime(auction)} · 입찰 ${auction.bidCount}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _accentColor(auction.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AuctionStatus status) {
    return switch (status) {
      AuctionStatus.waiting => '경매 시작 전',
      AuctionStatus.active => '경매 진행 중',
      AuctionStatus.completed => '낙찰 완료',
    };
  }

  String _currentPriceLabel(String price) {
    if (price.startsWith('현재가')) return price;
    if (price.startsWith('현재 ')) return price.replaceFirst('현재 ', '현재가 ');
    return '현재가 $price';
  }

  String _remainingTime(AuctionPreview auction) {
    if (auction.status == AuctionStatus.completed ||
        auction.remainingTime <= Duration.zero) {
      return '경매 종료';
    }

    final hours = auction.remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = auction.remainingTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = auction.remainingTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Color _accentColor(AuctionStatus status) {
    return status == AuctionStatus.completed
        ? AppColors.textSecondary
        : AppColors.auction;
  }
}

class _AuctionImage extends StatelessWidget {
  const _AuctionImage({this.imageAsset});

  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.imageBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageAsset == null
          ? const Center(
              child: Icon(
                Icons.gavel_outlined,
                size: 60,
                color: AppColors.iconDisabled,
              ),
            )
          : Image.asset(imageAsset!, fit: BoxFit.cover),
    );
  }
}
