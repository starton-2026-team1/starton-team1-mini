import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

class AppFilterChipBar<T> extends StatelessWidget {
  const AppFilterChipBar({
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    super.key,
  });

  final List<T> items;
  final T selectedItem;
  final String Function(T item) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selectedItem;
          final label = labelBuilder(item);
          final scaledFontSize = MediaQuery.textScalerOf(context).scale(13);
          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(item),
            showCheckmark: false,
            // Flutter Web에서 한글 폭이 한 글자로 계산되는 경우를 막는 최소 너비
            label: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: label.runes.length * scaledFontSize,
              ),
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            ),
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
