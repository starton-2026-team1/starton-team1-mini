import 'package:flutter/material.dart';

import '../models/product_preview.dart';
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
  int _selectedCategoryIndex = 0;
  bool _isCreateMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const ProductListHeader(),
              ProductCategoryBar(
                selectedIndex: _selectedCategoryIndex,
                onSelected: (index) {
                  setState(() => _selectedCategoryIndex = index);
                },
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: mockProducts.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF0F1F3)),
                  itemBuilder: (context, index) {
                    return ProductListItem(product: mockProducts[index]);
                  },
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
                    onSelected: (_) => _closeCreateMenu(),
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
}
