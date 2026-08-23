import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';

import '../models/product_sell_form.dart';

class ProductApi {
  ProductApi({ApiClient? apiClient, AuthTokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  Future<Map<String, dynamic>> createProduct(ProductSellForm form) async {
    debugPrint('토큰 읽기 시작');

    final accessToken = await _tokenStorage.readAccessToken();

    debugPrint('토큰 읽기 완료');

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    debugPrint('상품 API 요청 시작');

    final files = <http.MultipartFile>[];

    for (final imagePath in form.imagePaths) {
      files.add(await http.MultipartFile.fromPath('images', imagePath));
    }

    final response = await _apiClient.postMultipart(
      '/products',
      headers: {'Authorization': 'Bearer $accessToken'},
      fields: {
        'category_id': '1',
        'sale_type': 'FIXED_PRICE',
        'title': form.title,
        'description': form.description,
        'price': form.price.toString(),
      },
      files: files,
    );

    debugPrint('상품 API 요청 성공');

    return response;
  }

  void close() {
    _apiClient.close();
  }
}
