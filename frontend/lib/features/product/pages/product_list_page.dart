import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';
import 'package:frontend/shared/widgets/refreshable_empty_state.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../../auction/pages/auction_create_page.dart';
import '../../auction/services/auction_draft_storage.dart';
import '../../auction/widgets/auction_draft_dialog.dart';
import '../data/combined_product_feed.dart';
import '../models/product_category.dart';
import '../models/product_feed_item.dart';
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
  CombinedProductFeedData? _feedData;
  bool _isLoadingMoreProducts = false;
  bool _isLoadingMoreAuctions = false;
  bool _isRefreshing = false;
  int _requestGeneration = 0;
  ProductCategory _selectedCategory = ProductCategory.all;
  bool _isCreateMenuOpen = false;
  bool _isTopMenuVisible = true;

  @override
  void initState() {
    super.initState();
    _feedFuture = _loadInitialFeed();
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
                          onSelected: _selectCategory,
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ),
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: _handleScrollDirection,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleProductPagination,
                    child: _buildSelectedCategory(),
                  ),
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

      final createdProduct = await Navigator.of(context).push<Object?>(
        MaterialPageRoute(builder: (_) => const ProductSellPage()),
      );
      if (createdProduct != null) await _refreshFeed();
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

      final createdAuction = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(builder: (_) => const AuctionCreatePage()),
      );
      if (createdAuction ?? false) await _refreshFeed();
    }
  }

  void _selectCategory(ProductCategory category) {
    if (category == _selectedCategory) return;

    setState(() => _selectedCategory = category);
    // 다른 탭에서 경매 탭으로 들어갈 때 새로 등록된 경매 목록 갱신
    if (category == ProductCategory.auction) unawaited(_refreshFeed());
  }

  Widget _buildSelectedCategory() {
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
        if (_selectedCategory == ProductCategory.auction) {
          if (data.auctions.isEmpty) {
            return RefreshableEmptyState(
              message: '등록된 경매가 없어요.',
              onRefresh: _refreshFeed,
            );
          }
          return CombinedProductList(
            items: data.auctions.map(ProductFeedItem.auction).toList(),
            onRefresh: _refreshFeed,
            isLoadingMore: _isLoadingMoreAuctions,
          );
        }

        if (_selectedCategory == ProductCategory.all) {
          if (data.items.isEmpty) {
            return RefreshableEmptyState(
              message: '등록된 상품이 없어요.',
              onRefresh: _refreshFeed,
            );
          }
          return CombinedProductList(
            items: data.items,
            onRefresh: _refreshFeed,
            isLoadingMore: _isLoadingMoreProducts || _isLoadingMoreAuctions,
          );
        }

        final products = data.products
            .where((product) => product.category == _selectedCategory)
            .toList();
        if (products.isEmpty) {
          return RefreshableEmptyState(
            message: '등록된 상품이 없어요.',
            onRefresh: _refreshFeed,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length + (_isLoadingMoreProducts ? 1 : 0),
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.borderSubtle),
            itemBuilder: (context, index) {
              if (index == products.length) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ProductListItem(product: products[index]);
            },
          ),
        );
      },
    );
  }

  Future<void> _refreshFeed() async {
    final generation = ++_requestGeneration;
    _isLoadingMoreProducts = false;
    _isLoadingMoreAuctions = false;
    _isRefreshing = true;
    try {
      final data = await _feedApi.load();
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _feedData = data;
        _feedFuture = Future.value(data);
      });
    } on ApiException catch (error) {
      if (mounted && generation == _requestGeneration) {
        showAppSnackBar(context, error.message);
      }
    } catch (_) {
      if (mounted && generation == _requestGeneration) {
        showAppSnackBar(context, '새로고침하지 못했어요.');
      }
    } finally {
      if (generation == _requestGeneration) _isRefreshing = false;
    }
  }

  Future<CombinedProductFeedData> _loadInitialFeed() async {
    final generation = ++_requestGeneration;
    final data = await _feedApi.load();
    if (generation == _requestGeneration) _feedData = data;
    return data;
  }

  Future<void> _loadMoreProducts() async {
    final currentData = _feedData;
    if (currentData == null ||
        !currentData.hasMoreProducts ||
        _isLoadingMoreProducts ||
        _isRefreshing) {
      return;
    }

    setState(() => _isLoadingMoreProducts = true);
    final generation = _requestGeneration;
    try {
      final page = await _feedApi.loadProducts(
        offset: currentData.nextProductOffset,
      );
      if (!mounted || generation != _requestGeneration) return;
      final latestData = _feedData;
      if (latestData == null) return;
      final updatedData = latestData.appendProducts(page);
      setState(() {
        _feedData = updatedData;
        _feedFuture = Future.value(updatedData);
      });
    } on ApiException catch (error) {
      if (mounted) showAppSnackBar(context, error.message);
    } catch (_) {
      if (mounted) showAppSnackBar(context, '다음 상품을 불러오지 못했어요.');
    } finally {
      if (mounted) setState(() => _isLoadingMoreProducts = false);
    }
  }

  Future<void> _loadMoreAuctions() async {
    final currentData = _feedData;
    if (currentData == null ||
        !currentData.hasMoreAuctions ||
        _isLoadingMoreAuctions ||
        _isRefreshing) {
      return;
    }

    setState(() => _isLoadingMoreAuctions = true);
    final generation = _requestGeneration;
    try {
      final page = await _feedApi.loadAuctions(
        offset: currentData.nextAuctionOffset,
      );
      if (!mounted || generation != _requestGeneration) return;
      final latestData = _feedData;
      if (latestData == null) return;
      final updatedData = latestData.appendAuctions(page);
      setState(() {
        _feedData = updatedData;
        _feedFuture = Future.value(updatedData);
      });
    } on ApiException catch (error) {
      if (mounted) showAppSnackBar(context, error.message);
    } catch (_) {
      if (mounted) showAppSnackBar(context, '다음 경매를 불러오지 못했어요.');
    } finally {
      if (mounted) setState(() => _isLoadingMoreAuctions = false);
    }
  }

  bool _handleProductPagination(ScrollNotification notification) {
    if (notification.metrics.extentAfter > 300) {
      return false;
    }
    if (_selectedCategory == ProductCategory.auction) {
      _loadMoreAuctions();
      return false;
    }
    _loadMoreProducts();
    if (_selectedCategory == ProductCategory.all) _loadMoreAuctions();
    return false;
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
