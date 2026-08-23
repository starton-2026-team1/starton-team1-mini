import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_config.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/auction_api.dart';
import '../models/auction_detail.dart';
import '../models/auction_status.dart';
import '../models/auction_update_message.dart';

class AuctionDetailPage extends StatefulWidget {
  const AuctionDetailPage({required this.auctionId, super.key});

  final int auctionId;

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  final _auctionApi = AuctionApi(ApiClient(), AuthTokenStorage());

  AuctionDetail? _auction;
  bool _isLoading = true;
  String? _loadError;

  Duration _remainingTime = Duration.zero;
  List<AuctionBidPreview> _bids = const [];
  int _currentPrice = 0;
  Timer? _timer;
  bool _isFavorite = false;
  bool _isBidding = false;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _socketReconnectTimer;

  @override
  void initState() {
    super.initState();
    _loadAuction();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socketSubscription?.cancel();
    _socketReconnectTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _loadAuction() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final auction = await _auctionApi.getAuctionDetail(widget.auctionId);
      if (!mounted) return;
      setState(() {
        _auction = auction;
        _bids = auction.bids;
        _currentPrice = auction.currentPrice;
        _remainingTime = auction.remainingTime;
        _isLoading = false;
      });
      _startStatusTimer(auction);
      if (auction.status == AuctionStatus.active) _connectSocket();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = '경매 정보를 불러오지 못했어요.';
        _isLoading = false;
      });
    }
  }

  void _startStatusTimer(AuctionDetail auction) {
    _timer?.cancel();
    if (!auction.status.hasRunningTimer) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingTime > const Duration(seconds: 1)) {
        setState(() => _remainingTime -= const Duration(seconds: 1));
        return;
      }

      timer.cancel();
      setState(() => _remainingTime = Duration.zero);
      unawaited(_reloadStatusAfterDeadline());
    });
  }

  Future<void> _reloadStatusAfterDeadline() async {
    try {
      // 시작 또는 종료 시각 도달 후 서버에서 계산한 최신 경매 상태 재조회
      final auction = await _auctionApi.getAuctionDetail(widget.auctionId);
      if (!mounted) return;
      setState(() {
        _auction = auction;
        _bids = auction.bids;
        _currentPrice = auction.currentPrice;
        _remainingTime = auction.remainingTime;
      });
      _startStatusTimer(auction);
      if (auction.status == AuctionStatus.active) _connectSocket();
    } catch (_) {
      // 상태 재조회 실패 시 기존 상세 정보 유지
    }
  }

  void _connectSocket() {
    _socketReconnectTimer?.cancel();
    _socketSubscription?.cancel();
    _channel?.sink.close();
    final wsBaseUrl = ApiConfig.baseUrl.replaceFirst('http', 'ws');
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsBaseUrl/auctions/${widget.auctionId}/ws'),
      );
      _socketSubscription = _channel!.stream.listen(
        _onSocketMessage,
        onError: (_) => _scheduleSocketReconnect(),
        onDone: _scheduleSocketReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleSocketReconnect();
    }
  }

  void _scheduleSocketReconnect() {
    if (!mounted || _auction?.status != AuctionStatus.active) return;
    if (_socketReconnectTimer?.isActive ?? false) return;

    // 진행 중 경매의 웹소켓 연결 종료 시 3초 후 재연결
    _socketReconnectTimer = Timer(const Duration(seconds: 3), _connectSocket);
  }

  AuctionDetail get _liveAuction =>
      _auction!.copyWith(bids: _bids, currentPrice: _currentPrice);

  void _onSocketMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final update = AuctionUpdateMessage.fromJson(json);
      if (!mounted) return;
      setState(() {
        _currentPrice = update.currentPrice;
        _bids = [update.latestBid, ..._bids];
      });
    } catch (_) {
      // 잘못된 실시간 메시지는 화면 상태 변경 없이 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null || _auction == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError ?? '경매 정보를 불러오지 못했어요.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadAuction, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    final auction = _liveAuction;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _ProductImage(
                    imageUrls: auction.imageUrls,
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
              status: auction.status,
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
    final auction = _liveAuction;
    if (!auction.status.canBid) return;
    final minPrice = auction.nextBidPrice;
    final amountController = TextEditingController(text: '$minPrice');

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              final amount = int.tryParse(amountController.text);
              final errorText = amount == null
                  ? '금액을 입력해 주세요.'
                  : amount < minPrice
                  ? '${_formatPrice(minPrice)} 이상 입력해 주세요.'
                  : null;

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '입찰하기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${_formatPrice(minPrice)}부터 입찰할 수 있어요.'),
                    const SizedBox(height: 4),
                    Text(
                      '최소 입찰 단위 ${_formatPrice(auction.minimumBidUnit)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        suffixText: '원',
                        errorText: errorText,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '입찰 후에는 취소할 수 없어요.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
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
                        onPressed: (_isBidding || errorText != null)
                            ? null
                            : () {
                                Navigator.pop(sheetContext);
                                _placeBid(amount!);
                              },
                        child: Text(
                          amount == null
                              ? '입찰하기'
                              : '${_formatPrice(amount)} 입찰하기',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _placeBid(int amount) async {
    setState(() => _isBidding = true);
    try {
      await _auctionApi.placeBid(widget.auctionId, amount);
    } on ApiException catch (error) {
      if (mounted) showAppSnackBar(context, error.message);
    } finally {
      if (mounted) setState(() => _isBidding = false);
    }
  }
}

class _ProductImage extends StatefulWidget {
  const _ProductImage({
    required this.imageUrls,
    required this.onBack,
    required this.onShare,
    required this.onMore,
  });
  final List<String> imageUrls;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;

  @override
  State<_ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<_ProductImage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 330,
          width: double.infinity,
          color: const Color(0xFFE8E8E8),
          child: widget.imageUrls.isEmpty
              ? const _ImageFallback()
              : PageView.builder(
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) => Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImageFallback(),
                  ),
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
              '${_currentIndex + 1} / ${widget.imageUrls.isEmpty ? 1 : widget.imageUrls.length}',
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
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          ),
        ),
        Positioned(
          top: 8,
          right: 48,
          child: IconButton(
            onPressed: widget.onShare,
            icon: const Icon(Icons.share_outlined, size: 23),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: widget.onMore,
            icon: const Icon(Icons.more_vert, size: 24),
          ),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE8E8E8),
      child: Column(
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
          Row(
            children: [
              const Text(
                '실시간 경매',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '● ${_statusLabel(auction.status)}',
                style: TextStyle(
                  color: _statusColor(auction.status),
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
              _Metric(
                label: _timeMetricLabel(auction.status),
                value: auction.status.hasRunningTimer
                    ? _formatDuration(remainingTime)
                    : '-',
              ),
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
          Text(
            _statusDescription(auction.status),
            style: const TextStyle(color: Color(0xFF808080), fontSize: 11),
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
    required this.status,
    required this.favoriteCount,
    required this.isFavorite,
    required this.onFavorite,
    required this.onBid,
  });
  final int price;
  final AuctionStatus status;
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
              onPressed: status.canBid ? onBid : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFE5E5E5),
                disabledForegroundColor: const Color(0xFF8A8A8A),
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      status.canBid
                          ? '${_formatPrice(price)}부터 입찰하기'
                          : _bidButtonLabel(status),
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

String _statusLabel(AuctionStatus status) => switch (status) {
  AuctionStatus.waiting => '시작 전',
  AuctionStatus.active => '진행 중',
  AuctionStatus.completed => '종료',
  AuctionStatus.noBids => '유찰',
  AuctionStatus.cancelled => '취소됨',
  AuctionStatus.tradeCompleted => '거래 완료',
};

Color _statusColor(AuctionStatus status) => switch (status) {
  AuctionStatus.waiting => const Color(0xFF3974D6),
  AuctionStatus.active => const Color(0xFF0AB838),
  AuctionStatus.completed ||
  AuctionStatus.tradeCompleted => const Color(0xFF666666),
  AuctionStatus.noBids || AuctionStatus.cancelled => const Color(0xFFD04444),
};

String _timeMetricLabel(AuctionStatus status) =>
    status == AuctionStatus.waiting ? '시작까지' : '남은 시간';

String _statusDescription(AuctionStatus status) => switch (status) {
  AuctionStatus.waiting => '경매가 시작되면 입찰할 수 있어요.',
  AuctionStatus.active => '입찰 후에는 취소할 수 없어요.',
  AuctionStatus.completed => '입찰이 마감된 경매예요.',
  AuctionStatus.noBids => '입찰 없이 종료된 경매예요.',
  AuctionStatus.cancelled => '판매자가 취소한 경매예요.',
  AuctionStatus.tradeCompleted => '낙찰자와 거래가 완료됐어요.',
};

String _bidButtonLabel(AuctionStatus status) => switch (status) {
  AuctionStatus.waiting => '경매 시작 전이에요',
  AuctionStatus.active => '입찰하기',
  AuctionStatus.completed => '경매가 종료됐어요',
  AuctionStatus.noBids => '유찰된 경매예요',
  AuctionStatus.cancelled => '취소된 경매예요',
  AuctionStatus.tradeCompleted => '거래가 완료됐어요',
};

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
