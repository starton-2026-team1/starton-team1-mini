import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_config.dart';
import 'package:frontend/shared/network/api_exception.dart';

import '../models/sales_management_item.dart';

abstract interface class SalesManagementGateway {
  Future<List<SalesManagementItem>> listMyProducts();
}

class SalesManagementApi implements SalesManagementGateway {
  SalesManagementApi(this._client, this._tokenStorage);

  final ApiClient _client;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<List<SalesManagementItem>> listMyProducts() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'ACCESS_TOKEN_NOT_FOUND',
        message: '로그인이 필요합니다.',
      );
    }
    final json = await _client.get(
      '/products/me',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final items = json['items'] as List<dynamic>;
    return items
        .map(
          (item) => SalesManagementItem.fromJson(
            item as Map<String, dynamic>,
            mediaBaseUrl: ApiConfig.mediaBaseUrl,
          ),
        )
        .toList();
  }
}
