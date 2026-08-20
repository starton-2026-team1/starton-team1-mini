import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../chat/pages/chat_list_page.dart';
import '../../product/pages/product_list_page.dart';
import '../widgets/main_bottom_navigation_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

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
    const ColoredBox(color: AppColors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
