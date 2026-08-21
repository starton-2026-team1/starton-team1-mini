import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../chat/pages/chat_list_page.dart';
import '../../product/pages/product_list_page.dart';
import '../../profile/pages/profile_page.dart';
import '../widgets/main_bottom_navigation_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({this.userName = '사용자', super.key});

  final String userName;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const ProductListPage(),
    const ColoredBox(color: AppColors.white),
    const ColoredBox(color: AppColors.white),
    const ChatListPage(),
    ProfilePage(userName: widget.userName),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 4
          ? AppColors.surfaceMuted
          : AppColors.white,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
