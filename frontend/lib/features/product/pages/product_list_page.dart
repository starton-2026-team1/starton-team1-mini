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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => ProductCreateMenu.show(context),
        backgroundColor: const Color(0xFFFF6F0F),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 34, weight: 300),
      ),
    );
  }
}
