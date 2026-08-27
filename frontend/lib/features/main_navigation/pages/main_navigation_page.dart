import 'package:flutter/material.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../auth/data/auth_api.dart';
import '../../auth/pages/welcome_page.dart';
import '../../auth/services/auth_token_storage.dart';
import '../../chat/pages/chat_list_page.dart';
import '../../product/pages/product_list_page.dart';
import '../../product/data/sales_management_api.dart';
import '../../profile/pages/profile_page.dart';
import '../../profile/data/profile_api.dart';
import '../widgets/main_bottom_navigation_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({
    this.userId = 0,
    this.userName = '사용자',
    this.mannerTemperature = 36.5,
    this.authGateway,
    this.profileGateway,
    this.salesManagementGateway,
    super.key,
  });

  final int userId;
  final String userName;
  final double mannerTemperature;
  final AuthGateway? authGateway;
  final ProfileGateway? profileGateway;
  final SalesManagementGateway? salesManagementGateway;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  ApiClient? _apiClient;
  late final AuthGateway _authGateway;
  late final ProfileGateway _profileGateway;
  late final SalesManagementGateway _salesManagementGateway;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;

    if (widget.authGateway != null) {
      _authGateway = widget.authGateway!;
    } else {
      _apiClient = ApiClient();
      _authGateway = AuthApi(_apiClient!, AuthTokenStorage());
    }

    _profileGateway =
        widget.profileGateway ??
        ProfileApi(_apiClient ??= ApiClient(), AuthTokenStorage());
    _salesManagementGateway =
        widget.salesManagementGateway ??
        SalesManagementApi(_apiClient ??= ApiClient(), AuthTokenStorage());
  }

  List<Widget> get _pages => [
    const ProductListPage(),
    const ColoredBox(color: AppColors.white),
    const ColoredBox(color: AppColors.white),
    const ChatListPage(),
    ProfilePage(
      userId: widget.userId,
      userName: _userName,
      mannerTemperature: widget.mannerTemperature,
      profileGateway: _profileGateway,
      onNameUpdated: (name) => setState(() => _userName = name),
      onLogout: _logout,
      salesManagementGateway: _salesManagementGateway,
    ),
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
