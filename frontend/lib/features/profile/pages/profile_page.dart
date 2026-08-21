import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';

import '../data/profile_menu_data.dart';
import '../models/profile_menu_item.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section_card.dart';
import '../widgets/profile_shortcut_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.userName, this.onMenuTap, super.key});

  final String userName;
  final ValueChanged<ProfileMenuItem>? onMenuTap;

  void _handleTap(BuildContext context, ProfileMenuItem item) {
    if (onMenuTap != null) {
      onMenuTap!(item);
      return;
    }

    showAppSnackBar(context, '${item.label} 페이지는 준비 중이에요.', bottomMargin: 92);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surfaceMuted,
            surfaceTintColor: AppColors.transparent,
            title: const Text(
              '나의 당근',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    _handleTap(context, profileMenuSections.first.items.first),
                icon: const Icon(Icons.settings_outlined, size: 29),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            sliver: SliverList.list(
              children: [
                ProfileHeader(
                  userName: userName,
                  onTap: () => _handleTap(
                    context,
                    const ProfileMenuItem(
                      label: '프로필 수정',
                      icon: Icons.person_outline,
                      routeKey: 'profile_edit',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ProfileShortcutCard(
                  items: profileShortcuts,
                  onTap: (item) => _handleTap(context, item),
                ),
                for (final section in profileMenuSections) ...[
                  const SizedBox(height: 12),
                  ProfileMenuSectionCard(
                    section: section,
                    onTap: (item) => _handleTap(context, item),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
