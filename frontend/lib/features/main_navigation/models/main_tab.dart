import 'package:flutter/material.dart';

enum MainTab {
  home(label: '홈', icon: Icons.home_outlined, selectedIcon: Icons.home_rounded),
  neighborhood(
    label: '커뮤니티',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
  ),
  nearby(
    label: '동네지도',
    icon: Icons.location_on_outlined,
    selectedIcon: Icons.location_on,
  ),
  chat(
    label: '채팅',
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    badgeCount: 4,
  ),
  profile(
    label: '나의 당근',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  );

  const MainTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
}
