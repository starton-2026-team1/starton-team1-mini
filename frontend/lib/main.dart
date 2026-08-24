import 'package:flutter/material.dart';

import 'app/carrot_market_app.dart';
import 'features/auth/pages/welcome_page.dart';
import 'shared/network/api_client.dart';

bool _isHandlingSessionExpiry = false;

void main() {
  ApiClient.onSessionExpired = () async {
    if (_isHandlingSessionExpiry) return;
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    _isHandlingSessionExpiry = true;
    try {
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const WelcomePage()),
        (_) => false,
      );
    } finally {
      _isHandlingSessionExpiry = false;
    }
  };
  runApp(const CarrotMarketApp(home: WelcomePage()));
}
