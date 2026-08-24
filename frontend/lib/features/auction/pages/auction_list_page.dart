import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../data/auction_api.dart';
import '../models/auction_preview.dart';
import 'auction_detail_page.dart';
import '../widgets/auction_list_item.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  final _auctionApi = AuctionApi(ApiClient(), AuthTokenStorage());
  late Future<List<AuctionPreview>> _auctionsFuture;

  @override
  void initState() {
    super.initState();
    _auctionsFuture = _auctionApi.listAuctions();
  }

  Future<void> _refresh() async {
    final future = _auctionApi.listAuctions();
    setState(() => _auctionsFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuctionPreview>>(
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

        final auctions = snapshot.data ?? const [];
        if (auctions.isEmpty) {
          return const Center(
            child: Text(
              '등록된 경매가 없어요.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: auctions.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.borderSubtle),
            itemBuilder: (context, index) {
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
