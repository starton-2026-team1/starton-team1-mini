import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';

import '../models/auth_session.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';
import '../services/auth_token_storage.dart';

abstract interface class AuthGateway {
  Future<AuthSession> login(String phoneNumber);

  Future<AuthUser> getSession();

  Future<AuthTokens> refresh();

  Future<void> logout();
}

class AuthApi implements AuthGateway {
  AuthApi(this._client, this._tokenStorage);

  final ApiClient _client;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthSession> login(String phoneNumber) async {
    final json = await _client.post(
      '/auth/login',
      body: {'phone_number': phoneNumber},
    );
    final session = AuthSession.fromJson(json);

    await _tokenStorage.save(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );

    return session;
  }

  @override
  Future<AuthUser> getSession() async {
    final accessToken = await _requireAccessToken();
    final json = await _client.get(
      '/auth/session',
      headers: _authorization(accessToken),
    );

    return AuthUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthTokens> refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'REFRESH_TOKEN_NOT_FOUND',
        message: '로그인이 필요합니다.',
      );
    }

    final json = await _client.post(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
    );
    final tokens = AuthTokens.fromJson(json);

    await _tokenStorage.save(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  @override
  Future<void> logout() async {
    final accessToken = await _tokenStorage.readAccessToken();

    try {
      if (accessToken != null) {
        await _client.post(
          '/auth/logout',
          headers: _authorization(accessToken),
        );
      }
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<String> _requireAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'ACCESS_TOKEN_NOT_FOUND',
        message: '로그인이 필요합니다.',
      );
    }

    return accessToken;
  }

  Map<String, String> _authorization(String token) {
    return {'Authorization': 'Bearer $token'};
  }
}
