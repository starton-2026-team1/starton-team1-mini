import 'package:flutter/material.dart';

class ProductCategoryBar extends StatelessWidget {
  const ProductCategoryBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  static const categories = ['전체', '경매', '중고거래', '방금 전', '가까운 동네', '부동산'];

  final int selectedIndex;
  final ValueChanged<int> onSelected;

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
          final isSelected = index == selectedIndex;

          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(index),
            showCheckmark: false,
            label: Text(categories[index]),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF44464A),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            color: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF222D33);
              }
              return const Color(0xFFF5F5F6);
            }),
            pressElevation: 0,
            elevation: 0,
            shadowColor: Colors.transparent,
            selectedShadowColor: Colors.transparent,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          );
        },
      ),
    );
  }
}
