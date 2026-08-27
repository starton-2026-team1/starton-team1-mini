import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/app_filter_chip_bar.dart';

import '../models/product_category.dart';

class ProductCategoryBar extends StatelessWidget {
  const ProductCategoryBar({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  static const categories = ProductCategory.values;

  final ProductCategory selectedCategory;
  final ValueChanged<ProductCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppFilterChipBar<ProductCategory>(
      items: categories,
      selectedItem: selectedCategory,
      labelBuilder: (category) => category.label,
      onSelected: onSelected,
    );
  }
}
