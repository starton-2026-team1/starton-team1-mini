import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

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
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
            label: Text(category.label),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.white : AppColors.categoryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            color: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.categorySelected;
              }
              return AppColors.surfaceMuted;
            }),
            pressElevation: 0,
            elevation: 0,
            shadowColor: AppColors.transparent,
            selectedShadowColor: AppColors.transparent,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          );
        },
      ),
    );
  }
}
