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
    // 웹 구현은 첫 write에서 암호화 키를 생성하므로 두 write를 동시에
    // 실행하면 키 생성이 경합해 저장된 토큰을 다시 읽지 못할 수 있다.
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
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
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
