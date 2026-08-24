import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';

import '../data/auction_api.dart';
import '../models/auction_preview.dart';
import '../models/auction_page.dart';
import 'auction_detail_page.dart';
import '../widgets/auction_list_item.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({this.gateway, super.key});

  final AuctionGateway? gateway;

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  late final AuctionGateway _auctionGateway;
  late Future<AuctionPage> _auctionsFuture;
  AuctionPage? _auctionPage;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _auctionGateway =
        widget.gateway ?? AuctionApi(ApiClient(), AuthTokenStorage());
    _auctionsFuture = _loadInitial();
  }

  Future<void> _refresh() async {
    _auctionPage = null;
    _isLoadingMore = false;
    final future = _loadInitial();
    setState(() => _auctionsFuture = future);
    await future;
  }

  Future<AuctionPage> _loadInitial() async {
    final page = await _auctionGateway.listAuctions();
    _auctionPage = page;
    return page;
  }

  Future<void> _loadMore() async {
    final currentPage = _auctionPage;
    if (currentPage == null || !currentPage.hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      final nextPage = await _auctionGateway.listAuctions(
        offset: currentPage.nextOffset,
      );
      if (!mounted || _auctionPage != currentPage) return;
      final updatedPage = currentPage.append(nextPage);
      setState(() {
        _auctionPage = updatedPage;
        _auctionsFuture = Future.value(updatedPage);
      });
    } on ApiException catch (error) {
      if (mounted) showAppSnackBar(context, error.message);
    } catch (_) {
      if (mounted) showAppSnackBar(context, '다음 경매를 불러오지 못했어요.');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  bool _handlePagination(ScrollNotification notification) {
    if (notification.metrics.extentAfter <= 300) _loadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuctionPage>(
      future: _auctionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ApiException
              ? error.message
              : '경매 목록을 불러오지 못했어요.';
          return _ErrorState(message: message, onRetry: _refresh);
        }

        final auctions = snapshot.data?.items ?? const <AuctionPreview>[];
        if (auctions.isEmpty) {
          return const Center(
            child: Text(
              '등록된 경매가 없어요.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: _handlePagination,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: auctions.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.borderSubtle),
              itemBuilder: (context, index) {
                if (index == auctions.length) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final auction = auctions[index];
                return AuctionListItem(
                  auction: auction,
                  onEnded: _refresh,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AuctionDetailPage(auctionId: auction.id),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
