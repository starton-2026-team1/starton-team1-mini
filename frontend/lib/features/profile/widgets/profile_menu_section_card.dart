import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../data/profile_menu_data.dart';
import '../models/profile_menu_item.dart';

class ProfileMenuSectionCard extends StatelessWidget {
  const ProfileMenuSectionCard({
    required this.section,
    required this.onTap,
    super.key,
  });

  final ProfileMenuSection section;
  final ValueChanged<ProfileMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textStrong,
              ),
            ),
            const SizedBox(height: 10),
            for (final item in section.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: 54,
                leading: Icon(item.icon, color: AppColors.textStrong, size: 27),
                title: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textStrong,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
                onTap: () => onTap(item),
              ),
          ],
        ),
      ),
    );
  }
}
