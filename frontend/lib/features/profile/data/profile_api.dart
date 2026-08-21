import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';

abstract interface class ProfileGateway {
  Future<String> updateName(String name);
}

class ProfileApi implements ProfileGateway {
  ProfileApi(this._client, this._tokenStorage);

  final ApiClient _client;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<String> updateName(String name) async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'ACCESS_TOKEN_NOT_FOUND',
        message: '로그인이 필요합니다.',
      );
    }

    final json = await _client.patch(
      '/users/me',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'name': name},
    );
    return json['name'] as String;
  }
}
