import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

class ProductCreateMenu extends StatelessWidget {
  const ProductCreateMenu({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _MenuCard(
            items: const [
              _MenuItem(
                label: '알바/과외/레슨',
                icon: Icons.person_search,
                color: AppColors.primary,
              ),
              _MenuItem(
                label: '부동산',
                icon: Icons.house_rounded,
                color: AppColors.menuAuction,
              ),
              _MenuItem(
                label: '중고차',
                icon: Icons.directions_car_rounded,
                color: AppColors.menuRequest,
              ),
              _MenuItem(
                label: '동네생활',
                icon: Icons.article_rounded,
                color: AppColors.menuJob,
              ),
              _MenuItem(
                label: '스토리',
                icon: Icons.play_circle_fill_rounded,
                color: AppColors.menuRealEstate,
              ),
            ],
            onSelected: (item) => onSelected(item.label),
          ),
          const SizedBox(height: 12),
          _MenuCard(
            items: const [
              _MenuItem(
                label: '여러 물건 팔기',
                icon: Icons.shopping_bag_rounded,
                color: AppColors.menuCar,
              ),
              _MenuItem(
                label: '경매 등록',
                icon: Icons.gavel_rounded,
                color: AppColors.menuClass,
              ),
              _MenuItem(
                label: '내 물건 팔기',
                icon: Icons.shopping_bag_rounded,
                color: AppColors.primary,
              ),
            ],
            onSelected: (item) => onSelected(item.label),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items, required this.onSelected});

  final List<_MenuItem> items;
  final ValueChanged<_MenuItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black10,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return InkWell(
            onTap: () => onSelected(item),
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 26),
                    const SizedBox(width: 14),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 16.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
