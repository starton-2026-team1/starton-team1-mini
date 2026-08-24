import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/shared/auth/auth_token_store.dart';

class AuthTokenStorage implements AuthTokenStore {
  AuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
