import 'package:flutter/material.dart';

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
            const SizedBox(width: 16),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.more_vert,
                          color: Color(0xFF969A9F),
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      auction.currentPrice,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        _AuctionBadge(status: auction.status),
                        const SizedBox(width: 8),
                        Text(
                          auction.remainingTimeLabel,
                          style: const TextStyle(
                            color: Color(0xFF969A9F),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '입찰 ${auction.bidCount}  ·  관심 ${auction.favoriteCount}',
                        style: const TextStyle(
                          color: Color(0xFF969A9F),
                          fontSize: 11,
                        ),
                      ),
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
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE3E4E7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageAsset == null
          ? const Icon(Icons.gavel_rounded, color: Color(0xFFDDDDE3), size: 58)
          : Image.asset(imageAsset!, fit: BoxFit.cover),
    );
  }
}

class _AuctionBadge extends StatelessWidget {
  const _AuctionBadge({required this.status});

  final AuctionStatus status;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (status) {
      AuctionStatus.waiting => (
        const Color(0xFFF1F3F5),
        const Color(0xFF5F6368),
      ),
      AuctionStatus.active => (
        const Color(0xFFFFF2E9),
        const Color(0xFFFF6F0F),
      ),
      AuctionStatus.completed => (
        const Color(0xFFEFF6FF),
        const Color(0xFF3B82F6),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          status.label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
