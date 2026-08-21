import 'package:flutter/material.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../auth/data/auth_api.dart';
import '../../auth/pages/welcome_page.dart';
import '../../auth/services/auth_token_storage.dart';
import '../../chat/pages/chat_list_page.dart';
import '../../product/pages/product_list_page.dart';
import '../../profile/pages/profile_page.dart';
import '../widgets/main_bottom_navigation_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({
    this.userName = '사용자',
    this.authGateway,
    super.key,
  });

  final String userName;
  final AuthGateway? authGateway;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  ApiClient? _apiClient;
  late final AuthGateway _authGateway;

  @override
  void initState() {
    super.initState();

    if (widget.authGateway != null) {
      _authGateway = widget.authGateway!;
      return;
    }

    _apiClient = ApiClient();
    _authGateway = AuthApi(_apiClient!, AuthTokenStorage());
  }

  late final List<Widget> _pages = [
    const ProductListPage(),
    const ColoredBox(color: AppColors.white),
    const ColoredBox(color: AppColors.white),
    const ChatListPage(),
    ProfilePage(userName: widget.userName, onLogout: _logout),
  ];

  Future<void> _logout() async {
    await _authGateway.logout();

    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _apiClient?.close();
    super.dispose();
  }

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
