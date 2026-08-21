import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 상세'),
      ),
      body: const Center(
        child: Text('상품 상세 페이지'),
      ),
    );
  }
}
