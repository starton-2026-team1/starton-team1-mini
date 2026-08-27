import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _overrideUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) {
      return _overrideUrl;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get mediaBaseUrl => baseUrl.replaceFirst('/api/v1', '');
}
