import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_filter_chip_bar.dart';

import '../../auth/services/auth_token_storage.dart';
import '../../../shared/network/api_client.dart';
import '../../auction/pages/auction_detail_page.dart';
import '../controllers/sales_management_controller.dart';
import '../data/sales_management_api.dart';
import '../models/product_category.dart';
import '../models/product_preview.dart';
import '../models/sales_management_filter.dart';
import '../models/sales_management_item.dart';
import '../widgets/sales_management_item_card.dart';
import 'product_detail_page.dart';

class SalesManagementPage extends StatefulWidget {
  const SalesManagementPage({
    this.gateway,
    this.auctionDetailBuilder,
    this.productDetailBuilder,
    super.key,
  });

  final SalesManagementGateway? gateway;
  final Widget Function(int auctionId)? auctionDetailBuilder;
  final Widget Function(SalesManagementItem item)? productDetailBuilder;

  @override
  State<SalesManagementPage> createState() => _SalesManagementPageState();
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  late final SalesManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SalesManagementController(
      widget.gateway ?? SalesManagementApi(ApiClient(), AuthTokenStorage()),
    )..addListener(_onChanged);
    _controller.load();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMuted,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: const Text(
          '판매/경매관리',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFilterChipBar<SalesManagementFilter>(
            items: SalesManagementFilter.values,
            selectedItem: _controller.selectedFilter,
            labelBuilder: (filter) =>
                '${filter.label} ${_controller.countFor(filter)}',
            onSelected: _controller.selectFilter,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_controller.errorMessage!),
            const SizedBox(height: 8),
            TextButton(onPressed: _controller.load, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    final items = _controller.filteredItems;
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(child: Text('해당하는 판매 상품이 없어요.')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SalesManagementItemCard(
            item: item,
            onTap: () => _openDetail(item),
          );
        },
      ),
    );
  }

  Future<void> _openDetail(SalesManagementItem item) async {
    Widget page;
    if (item.isAuction) {
      final auctionId = item.auctionId;
      if (auctionId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('경매 정보를 확인할 수 없어요.')));
        return;
      }
      page =
          widget.auctionDetailBuilder?.call(auctionId) ??
          AuctionDetailPage(auctionId: auctionId);
    } else {
      page =
          widget.productDetailBuilder?.call(item) ??
          ProductDetailPage(product: _toProductPreview(item));
    }
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => page));
    if (mounted) await _controller.load();
  }

  ProductPreview _toProductPreview(SalesManagementItem item) {
    return ProductPreview(
      category: ProductCategory.used,
      title: item.title,
      description: item.description,
      location: item.location,
      time: item.timeLabel,
      price: '${_formatPrice(item.price)}원',
      imageUrls: item.imageUrl == null ? const [] : [item.imageUrl!],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }
}
