import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';

import '../models/auction_detail.dart';

class AuctionDetailPage extends StatefulWidget {
  const AuctionDetailPage({this.auction = mockAuctionDetail, super.key});

  final AuctionDetail auction;

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  late Duration _remainingTime = widget.auction.remainingTime;
  Timer? _timer;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remainingTime <= Duration.zero) return;
      setState(() => _remainingTime -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _ProductImage(
                    imageCount: auction.imageCount,
                    onBack: () => Navigator.maybePop(context),
                    onShare: () => showAppSnackBar(context, '공유 기능을 준비 중이에요.'),
                    onMore: _showMoreMenu,
                  ),
                  _SellerSummary(auction: auction),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF2F3F5),
                  ),
                  _ProductSummary(auction: auction),
                  const _SectionDivider(),
                  _AuctionStatusSection(
                    auction: auction,
                    remainingTime: _remainingTime,
                  ),
                  const _SectionDivider(),
                  _BidHistory(auction: auction),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _BidBar(
              price: auction.nextBidPrice,
              favoriteCount: auction.favoriteCount + (_isFavorite ? 1 : 0),
              isFavorite: _isFavorite,
              onFavorite: () => setState(() => _isFavorite = !_isFavorite),
              onBid: _showBidSheet,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: const Text('게시글 신고하기'),
          onTap: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showBidSheet() {
    final price = widget.auction.nextBidPrice;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '입찰하기',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('${_formatPrice(price)}부터 입찰할 수 있어요.'),
              const SizedBox(height: 4),
              Text(
                '최소 입찰 단위 ${_formatPrice(widget.auction.minimumBidUnit)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '입찰 후에는 취소할 수 없어요.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    showAppSnackBar(context, 'API 연결 후 실제 입찰이 진행돼요.');
                  },
                  child: Text(
                    '${_formatPrice(price)} 입찰하기',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageCount,
    required this.onBack,
    required this.onShare,
    required this.onMore,
  });
  final int imageCount;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 330,
          width: double.infinity,
          color: const Color(0xFFE8E8E8),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 50, color: Color(0xFF8C8C8C)),
              SizedBox(height: 8),
              Text(
                '상품 사진',
                style: TextStyle(color: Color(0xFF666666), fontSize: 13),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xC72E2E2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '1 / $imageCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          ),
        ),
        Positioned(
          top: 8,
          right: 48,
          child: IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined, size: 23),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_vert, size: 24),
          ),
        ),
      ],
    );
  }
}

class _SellerSummary extends StatelessWidget {
  const _SellerSummary({required this.auction});
  final AuctionDetail auction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE9EAEC),
            child: Icon(Icons.person, size: 25, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.sellerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  auction.location,
                  style: const TextStyle(
                    color: Color(0xFF868B94),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${auction.mannerTemperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _mannerEmoji(auction.mannerTemperature),
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                '매너온도',
                style: TextStyle(color: Color(0xFF868B94), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.auction});
  final AuctionDetail auction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            auction.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Text(
                '시작가',
                style: TextStyle(color: Color(0xFF616161), fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                _formatPrice(auction.startPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${auction.category} · 끌올 3분 전',
            style: const TextStyle(color: Color(0xFF868B94), fontSize: 11),
          ),
          const SizedBox(height: 18),
          Text(
            auction.description,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionStatusSection extends StatelessWidget {
  const _AuctionStatusSection({
    required this.auction,
    required this.remainingTime,
  });
  final AuctionDetail auction;
  final Duration remainingTime;

  @override
  Widget build(BuildContext context) {
    final latestBid = auction.bids.firstOrNull;
    final displayedPrice = latestBid == null
        ? auction.startPrice
        : auction.currentPrice;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '실시간 경매',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '● 진행 중',
                style: TextStyle(
                  color: Color(0xFF0AB838),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(
                label: latestBid == null ? '시작가' : '현재 입찰가',
                value: _formatPrice(displayedPrice),
                large: true,
              ),
              const SizedBox(width: 34),
              _Metric(label: '남은 시간', value: _formatDuration(remainingTime)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '최소 입찰 단위  ${_formatPrice(auction.minimumBidUnit)}',
            style: const TextStyle(
              color: Color(0xFF737373),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '입찰 ${auction.bids.length}회',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 18),
                if (latestBid == null)
                  const Text(
                    '아직 입찰이 없어요',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                  )
                else ...[
                  Text(
                    '최근 입찰 ${latestBid.bidderName}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    latestBid.timeLabel,
                    style: const TextStyle(
                      color: Color(0xFF858585),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '입찰 후에는 취소할 수 없어요.',
            style: TextStyle(color: Color(0xFF808080), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.large = false});
  final String label;
  final String value;
  final bool large;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF737373), fontSize: 12),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          fontSize: large ? 22 : 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _BidHistory extends StatelessWidget {
  const _BidHistory({required this.auction});
  final AuctionDetail auction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
    child: Column(
      children: [
        Row(
          children: [
            const Text(
              '전체 입찰 내역',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '총 ${auction.bids.length}회',
              style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 12),
            ),
          ],
        ),
        ...auction.bids.map(
          (bid) => Container(
            height: 40,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    bid.bidderName,
                    style: const TextStyle(
                      color: Color(0xFF595959),
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatPrice(bid.amount),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  bid.timeLabel,
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 8, child: ColoredBox(color: Color(0xFFF5F5F5)));
}

class _BidBar extends StatelessWidget {
  const _BidBar({
    required this.price,
    required this.favoriteCount,
    required this.isFavorite,
    required this.onFavorite,
    required this.onBid,
  });
  final int price;
  final int favoriteCount;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onBid;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: InkWell(
              onTap: onFavorite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 24,
                    color: isFavorite
                        ? AppColors.primary
                        : const Color(0xFF1A1A1A),
                  ),
                  Text(
                    '$favoriteCount',
                    style: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 38, color: const Color(0xFFE0E0E0)),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onBid,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_formatPrice(price)}부터 입찰하기',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String _mannerEmoji(double temperature) {
  if (temperature >= 50) return '😍';
  if (temperature >= 40) return '😄';
  if (temperature >= 30) return '😊';
  return '😐';
}

String _formatPrice(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  buffer.write('원');
  return buffer.toString();
}

String _formatDuration(Duration value) {
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
