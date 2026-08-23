import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../../auction/pages/auction_list_page.dart';
import '../../auction/pages/auction_create_page.dart';
import '../../auction/services/auction_draft_storage.dart';
import '../../auction/widgets/auction_draft_dialog.dart';
import '../data/combined_product_feed.dart';
import '../models/product_category.dart';
import '../services/product_sell_draft_storage.dart';
import 'product_sell_page.dart';
import '../widgets/combined_product_list.dart';
import '../widgets/product_category_bar.dart';
import '../widgets/product_create_menu.dart';
import '../widgets/product_list_header.dart';
import '../widgets/product_list_item.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _feedApi = CombinedProductFeedApi(ApiClient());
  late Future<CombinedProductFeedData> _feedFuture;
  ProductCategory _selectedCategory = ProductCategory.all;
  bool _isCreateMenuOpen = false;
  bool _isTopMenuVisible = true;

  @override
  void initState() {
    super.initState();
    _feedFuture = _feedApi.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const ProductListHeader(),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _isTopMenuVisible
                      ? ProductCategoryBar(
                          selectedCategory: _selectedCategory,
                          onSelected: (category) {
                            setState(() => _selectedCategory = category);
                          },
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ),
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: _handleScrollDirection,
                  child: _buildSelectedCategory(),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isCreateMenuOpen,
              child: AnimatedOpacity(
                opacity: _isCreateMenuOpen ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: GestureDetector(
                  onTap: _closeCreateMenu,
                  child: ColoredBox(
                    color: AppColors.black.withValues(alpha: 0.48),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 17,
            bottom: 84,
            child: IgnorePointer(
              ignoring: !_isCreateMenuOpen,
              child: AnimatedSlide(
                offset: _isCreateMenuOpen ? Offset.zero : const Offset(0, 0.05),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _isCreateMenuOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: ProductCreateMenu(
                    onSelected: _handleCreateMenuSelected,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _isCreateMenuOpen = !_isCreateMenuOpen);
        },
        backgroundColor: _isCreateMenuOpen
            ? AppColors.white
            : AppColors.primary,
        foregroundColor: _isCreateMenuOpen
            ? AppColors.textStrong
            : AppColors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: AnimatedRotation(
          turns: _isCreateMenuOpen ? -0.125 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: const Icon(Icons.add, size: 34, weight: 300),
        ),
      ),
    );
  }

  void _closeCreateMenu() {
    setState(() => _isCreateMenuOpen = false);
  }

  Future<void> _handleCreateMenuSelected(String label) async {
    _closeCreateMenu();
    if (label == '내 물건 팔기') {
      final storage = ProductSellDraftStorage();
      final draft = await storage.load();
      if (!mounted) return;

      if (draft != null) {
        final choice = await showAuctionDraftDialog(
          context: context,
          title: '작성 중인 글이 있어요',
          message: '글을 이어서 쓸까요?',
          primaryLabel: '이어서 쓰기',
          secondaryLabel: '새로 쓰기',
        );
        if (!mounted || choice == null) return;
        if (choice == AuctionDraftChoice.secondary) {
          await storage.clear();
          if (!mounted) return;
        }
      }

      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => const ProductSellPage()));
      await _refreshFeed();
      return;
    }

    if (label == '경매 등록') {
      final storage = AuctionDraftStorage();
      final draft = await storage.load();
      if (!mounted) return;

      if (draft != null) {
        final choice = await showAuctionDraftDialog(
          context: context,
          title: '작성 중인 글이 있어요',
          message: '글을 이어서 쓸까요?',
          primaryLabel: '이어서 쓰기',
          secondaryLabel: '새로 쓰기',
        );
        if (!mounted || choice == null) return;
        if (choice == AuctionDraftChoice.secondary) {
          await storage.clear();
          if (!mounted) return;
        }
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AuctionCreatePage()),
      );
      await _refreshFeed();
    }
  }

  Widget _buildSelectedCategory() {
    if (_selectedCategory == ProductCategory.auction) {
      return const AuctionListPage();
    }

    return FutureBuilder<CombinedProductFeedData>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ApiException
              ? error.message
              : '상품 목록을 불러오지 못했어요.';
          return _ProductListError(message: message, onRetry: _refreshFeed);
        }

        final data = snapshot.data!;
        if (_selectedCategory == ProductCategory.all) {
          if (data.items.isEmpty) {
            return const Center(child: Text('등록된 상품이 없어요.'));
          }
          return CombinedProductList(
            items: data.items,
            onRefresh: _refreshFeed,
          );
        }

        final products = data.products
            .where((product) => product.category == _selectedCategory)
            .toList();
        if (products.isEmpty) {
          return const Center(child: Text('등록된 상품이 없어요.'));
        }

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.borderSubtle),
            itemBuilder: (context, index) {
              return ProductListItem(product: products[index]);
            },
          ),
        );
      },
    );
  }

  Future<void> _refreshFeed() async {
    final future = _feedApi.load();
    setState(() => _feedFuture = future);
    await future;
  }

  bool _handleScrollDirection(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse &&
        _isTopMenuVisible) {
      setState(() => _isTopMenuVisible = false);
    } else if (notification.direction == ScrollDirection.forward &&
        !_isTopMenuVisible) {
      setState(() => _isTopMenuVisible = true);
    }

    return false;
  }
}

class _ProductListError extends StatelessWidget {
  const _ProductListError({required this.message, required this.onRetry});

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
