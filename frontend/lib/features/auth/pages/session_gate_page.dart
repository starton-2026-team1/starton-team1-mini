import 'package:flutter/material.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../main_navigation/pages/main_navigation_page.dart';
import '../data/auth_api.dart';
import '../models/auth_user.dart';
import '../services/auth_token_storage.dart';
import 'welcome_page.dart';

class SessionGatePage extends StatefulWidget {
  const SessionGatePage({this.authGateway, super.key});

  final AuthGateway? authGateway;

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  ApiClient? _apiClient;
  late final AuthGateway _authGateway;
  late final Future<AuthUser> _session;

  @override
  void initState() {
    super.initState();
    if (widget.authGateway case final authGateway?) {
      _authGateway = authGateway;
    } else {
      _apiClient = ApiClient();
      _authGateway = AuthApi(_apiClient!, AuthTokenStorage());
    }
    _session = _authGateway.getSession();
  }

  @override
  void dispose() {
    _apiClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthUser>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const WelcomePage();
        }

        return MainNavigationPage(
          userId: user.id,
          userName: user.name,
          authGateway: _authGateway,
        );
      },
    );
  }
}
