import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../models/profile_menu_item.dart';

class ProfileShortcutCard extends StatelessWidget {
  const ProfileShortcutCard({
    required this.items,
    required this.onTap,
    super.key,
  });

  final List<ProfileMenuItem> items;
  final ValueChanged<ProfileMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0)
                const SizedBox(
                  height: 38,
                  child: VerticalDivider(color: AppColors.borderSubtle),
                ),
              Expanded(
                child: InkWell(
                  onTap: () => onTap(items[index]),
                  child: Column(
                    children: [
                      Icon(
                        items[index].icon,
                        size: 30,
                        color: AppColors.textStrong,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        items[index].label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
