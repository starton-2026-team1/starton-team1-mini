import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../models/auction_preview.dart';
import '../models/auction_status.dart';

class AuctionListItem extends StatefulWidget {
  const AuctionListItem({
    required this.auction,
    this.onTap,
    this.onEnded,
    super.key,
  });

  final AuctionPreview auction;
  final VoidCallback? onTap;
  final VoidCallback? onEnded;

  @override
  State<AuctionListItem> createState() => _AuctionListItemState();
}

class _AuctionListItemState extends State<AuctionListItem> {
  Timer? _timer;
  late Duration _remainingTime;

  AuctionPreview get auction => widget.auction;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void didUpdateWidget(covariant AuctionListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auction.id != widget.auction.id ||
        oldWidget.auction.remainingTime != widget.auction.remainingTime ||
        oldWidget.auction.status != widget.auction.status) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingTime = auction.remainingTime;
    if (!auction.status.hasRunningTimer || _remainingTime <= Duration.zero) {
      return;
    }

    // 메인 및 경매 목록 카드의 남은 시간 1초 단위 갱신
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingTime > const Duration(seconds: 1)) {
        setState(() => _remainingTime -= const Duration(seconds: 1));
        return;
      }

      timer.cancel();
      setState(() => _remainingTime = Duration.zero);
      widget.onEnded?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: SizedBox(
        height: 170,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuctionImage(imageUrl: auction.thumbnailUrl),
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
                        '${auction.categoryName} · ${_statusLabel(auction.status)}',
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
                              '${auctionRemainingTimeLabel(auction.status, _remainingTime)} · 입찰 ${auction.bidCount}',
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
      ),
    );
  }

  String _statusLabel(AuctionStatus status) {
    return switch (status) {
      AuctionStatus.waiting => '경매 시작 전',
      AuctionStatus.active => '경매 진행 중',
      AuctionStatus.completed => '낙찰 완료',
      AuctionStatus.noBids => '유찰',
      AuctionStatus.cancelled => '경매 취소',
      AuctionStatus.tradeCompleted => '거래 완료',
    };
  }

  String _currentPriceLabel(String price) {
    if (price.startsWith('현재가')) return price;
    if (price.startsWith('현재 ')) return price.replaceFirst('현재 ', '현재가 ');
    return '현재가 $price';
  }

  Color _accentColor(AuctionStatus status) {
    return !status.hasRunningTimer
        ? AppColors.textSecondary
        : AppColors.auction;
  }
}

String auctionRemainingTimeLabel(AuctionStatus status, Duration remainingTime) {
  if (!status.hasRunningTimer) return status.label;
  if (remainingTime <= Duration.zero) {
    return status == AuctionStatus.waiting ? '곧 시작' : '경매 종료';
  }

  final days = remainingTime.inDays;
  final hours = remainingTime.inHours.remainder(24);
  final minutes = remainingTime.inMinutes.remainder(60);
  final seconds = remainingTime.inSeconds.remainder(60);
  final durationLabel = days > 0
      ? '$days일 $hours시간 $minutes분 $seconds초'
      : '${remainingTime.inHours}시간 $minutes분 $seconds초';

  return status == AuctionStatus.waiting
      ? '시작까지 $durationLabel'
      : durationLabel;
}

class _AuctionImage extends StatelessWidget {
  const _AuctionImage({this.imageUrl});

  final String? imageUrl;

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
      child: imageUrl == null
          ? const Center(
              child: Icon(
                Icons.gavel_outlined,
                size: 60,
                color: AppColors.iconDisabled,
              ),
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.gavel_outlined,
                  size: 60,
                  color: AppColors.iconDisabled,
                ),
              ),
            ),
    );
  }
}
