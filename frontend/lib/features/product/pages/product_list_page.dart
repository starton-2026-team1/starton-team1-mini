import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

import '../../auction/pages/auction_list_page.dart';
import '../../auction/pages/auction_create_page.dart';
import '../../auction/services/auction_draft_storage.dart';
import '../../auction/widgets/auction_draft_dialog.dart';
import '../data/combined_product_feed.dart';
import '../models/product_category.dart';
import '../models/product_preview.dart';
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
  ProductCategory _selectedCategory = ProductCategory.all;
  bool _isCreateMenuOpen = false;
  bool _isTopMenuVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: Colors.black.withValues(alpha: 0.48),
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
            ? Colors.white
            : const Color(0xFFFF6F0F),
        foregroundColor: _isCreateMenuOpen
            ? const Color(0xFF202124)
            : Colors.white,
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
    }
  }

  Widget _buildSelectedCategory() {
    if (_selectedCategory == ProductCategory.all) {
      return CombinedProductList(items: buildCombinedProductFeed());
    }

    if (_selectedCategory == ProductCategory.auction) {
      return const AuctionListPage();
    }

    final products = mockProducts
        .where((product) => product.category == _selectedCategory)
        .toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: products.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFF0F1F3)),
      itemBuilder: (context, index) {
        return ProductListItem(product: products[index]);
      },
    );
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
