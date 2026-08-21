import 'package:flutter/material.dart';

import '../models/profile_menu_item.dart';

const profileShortcuts = [
  ProfileMenuItem(
    label: '관심목록',
    icon: Icons.favorite_border,
    routeKey: 'favorites',
  ),
  ProfileMenuItem(label: '최근 본 글', icon: Icons.schedule, routeKey: 'recent'),
  ProfileMenuItem(
    label: '혜택',
    icon: Icons.diamond_outlined,
    routeKey: 'benefits',
  ),
];

const profileMenuSections = [
  ProfileMenuSection(
    title: '자주 사용',
    items: [
      ProfileMenuItem(
        label: '앱 설정',
        icon: Icons.settings_outlined,
        routeKey: 'settings',
      ),
    ],
  ),
  ProfileMenuSection(
    title: '나의 거래',
    items: [
      ProfileMenuItem(
        label: '판매관리',
        icon: Icons.receipt_long_outlined,
        routeKey: 'sales',
      ),
      ProfileMenuItem(
        label: '구매내역',
        icon: Icons.shopping_bag_outlined,
        routeKey: 'purchases',
      ),
      ProfileMenuItem(
        label: '내 물건 가격 찾기',
        icon: Icons.auto_awesome_outlined,
        routeKey: 'price_finder',
      ),
      ProfileMenuItem(
        label: '중고거래 가계부',
        icon: Icons.menu_book_outlined,
        routeKey: 'ledger',
      ),
    ],
  ),
  ProfileMenuSection(
    title: '나의 관심',
    items: [
      ProfileMenuItem(
        label: '관심목록',
        icon: Icons.favorite_border,
        routeKey: 'favorites',
      ),
      ProfileMenuItem(
        label: '키워드 알림 설정',
        icon: Icons.sell_outlined,
        routeKey: 'keyword_alerts',
      ),
    ],
  ),
  ProfileMenuSection(
    title: '나의 활동',
    items: [
      ProfileMenuItem(
        label: '동네생활 글과 댓글',
        icon: Icons.forum_outlined,
        routeKey: 'community_activity',
      ),
    ],
  ),
];

class ProfileMenuSection {
  const ProfileMenuSection({required this.title, required this.items});

  final String title;
  final List<ProfileMenuItem> items;
}
