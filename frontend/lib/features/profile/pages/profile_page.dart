import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_snack_bar.dart';

import '../../product/pages/sales_management_page.dart';
import '../../product/data/sales_management_api.dart';
import '../data/profile_menu_data.dart';
import '../data/profile_api.dart';
import '../models/profile_menu_item.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section_card.dart';
import '../widgets/profile_shortcut_card.dart';
import 'profile_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.userId,
    required this.userName,
    this.mannerTemperature = 37.9,
    required this.profileGateway,
    required this.onNameUpdated,
    this.onMenuTap,
    this.onLogout,
    this.salesManagementGateway,
    super.key,
  });

  final int userId;
  final String userName;
  final double mannerTemperature;
  final ProfileGateway profileGateway;
  final ValueChanged<String> onNameUpdated;
  final ValueChanged<ProfileMenuItem>? onMenuTap;
  final Future<void> Function()? onLogout;
  final SalesManagementGateway? salesManagementGateway;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  void _handleTap(BuildContext context, ProfileMenuItem item) {
    if (item.routeKey == 'profile_edit') {
      _openProfileDetail();
      return;
    }

    if (item.routeKey == 'logout') {
      _logout();
      return;
    }

    if (widget.onMenuTap != null) {
      widget.onMenuTap!(item);
      return;
    }

    if (item.routeKey == 'sales') {
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              SalesManagementPage(gateway: widget.salesManagementGateway),
        ),
      );
      return;
    }

    showAppSnackBar(context, '${item.label} 페이지는 준비 중이에요.', bottomMargin: 92);
  }

  Future<void> _openProfileDetail() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage(
          userId: widget.userId,
          userName: widget.userName,
          mannerTemperature: widget.mannerTemperature,
          profileGateway: widget.profileGateway,
          onNameUpdated: widget.onNameUpdated,
          salesManagementGateway: widget.salesManagementGateway,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (widget.onLogout == null || _isLoggingOut) {
      return;
    }

    setState(() => _isLoggingOut = true);

    try {
      await widget.onLogout!();
    } on Object {
      if (mounted) {
        showAppSnackBar(context, '로그아웃에 실패했어요. 다시 시도해 주세요.', bottomMargin: 92);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
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
                onPressed: () => _handleTap(
                  context,
                  const ProfileMenuItem(
                    label: '앱 설정',
                    icon: Icons.settings_outlined,
                    routeKey: 'app_settings',
                  ),
                ),
                tooltip: '앱 설정',
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
                  userName: widget.userName,
                  mannerTemperature: widget.mannerTemperature,
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
