import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/auth/auth_token_store.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  tearDown(() => ApiClient.onSessionExpired = null);

  test('401이면 토큰을 갱신하고 원 요청을 한 번 재시도한다', () async {
    final storage = _MemoryTokenStore(
      accessToken: 'expired-access',
      refreshToken: 'valid-refresh',
    );
    var bidRequestCount = 0;
    var refreshRequestCount = 0;
    final client = ApiClient(
      tokenStorage: storage,
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/refresh') {
          refreshRequestCount++;
          expect(jsonDecode(request.body)['refresh_token'], 'valid-refresh');
          return http.Response(
            jsonEncode({
              'access_token': 'new-access',
              'refresh_token': 'new-refresh',
            }),
            200,
          );
        }

        bidRequestCount++;
        if (bidRequestCount == 1) {
          expect(request.headers['authorization'], 'Bearer expired-access');
          return http.Response('{}', 401);
        }
        expect(request.headers['authorization'], 'Bearer new-access');
        return http.Response(jsonEncode({'ok': true}), 201);
      }),
    );

    final result = await client.post(
      '/auctions/12/bids',
      headers: {'Authorization': 'Bearer expired-access'},
      body: {'amount': 13000},
    );

    expect(result, {'ok': true});
    expect(refreshRequestCount, 1);
    expect(bidRequestCount, 2);
    expect(storage.accessToken, 'new-access');
    expect(storage.refreshToken, 'new-refresh');
  });

  test('토큰 갱신 실패 시 저장소를 비우고 만료 콜백을 호출한다', () async {
    final storage = _MemoryTokenStore(
      accessToken: 'expired-access',
      refreshToken: 'expired-refresh',
    );
    var sessionExpired = false;
    ApiClient.onSessionExpired = () async => sessionExpired = true;
    final client = ApiClient(
      tokenStorage: storage,
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/auth/refresh') {
          return http.Response('{}', 401);
        }
        return http.Response('{}', 401);
      }),
    );

    await expectLater(
      client.post(
        '/auctions/12/bids',
        headers: {'Authorization': 'Bearer expired-access'},
        body: {'amount': 13000},
      ),
      throwsA(isA<Exception>()),
    );

    expect(storage.accessToken, isNull);
    expect(storage.refreshToken, isNull);
    expect(sessionExpired, isTrue);
  });
}

class _MemoryTokenStore implements AuthTokenStore {
  _MemoryTokenStore({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
