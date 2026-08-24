import 'dart:convert';

import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/auth/auth_token_store.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, AuthTokenStore? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  static Future<void> Function()? onSessionExpired;

  final http.Client _client;
  final AuthTokenStore _tokenStorage;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _sendWithRefresh(
      path: path,
      headers: headers,
      send: (requestHeaders) =>
          _client.get(_uri(path), headers: requestHeaders),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _sendWithRefresh(
      path: path,
      headers: headers,
      send: (requestHeaders) => _client.post(
        _uri(path),
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    Map<String, String>? headers,
  }) async {
    final fileData = await Future.wait(
      files.map(
        (file) async => (
          field: file.field,
          bytes: await file.finalize().toBytes(),
          filename: file.filename,
          contentType: file.contentType,
        ),
      ),
    );
    final response = await _sendWithRefresh(
      path: path,
      headers: headers,
      send: (requestHeaders) async {
        final request = http.MultipartRequest('POST', _uri(path))
          ..headers.addAll(requestHeaders..remove('Content-Type'))
          ..fields.addAll(fields)
          ..files.addAll(
            fileData.map(
              (file) => http.MultipartFile.fromBytes(
                file.field,
                file.bytes,
                filename: file.filename,
                contentType: file.contentType,
              ),
            ),
          );
        return http.Response.fromStream(await _client.send(request));
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _sendWithRefresh(
      path: path,
      headers: headers,
      send: (requestHeaders) => _client.patch(
        _uri(path),
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Uri _uri(String path) {
    return Uri.parse('${ApiConfig.baseUrl}$path');
  }

  Map<String, String> _headers(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
  }

  Future<http.Response> _sendWithRefresh({
    required String path,
    required Map<String, String>? headers,
    required Future<http.Response> Function(Map<String, String> headers) send,
  }) async {
    final requestHeaders = _headers(headers);
    var response = await send(Map<String, String>.from(requestHeaders));

    final isAuthenticatedRequest = requestHeaders.containsKey('Authorization');
    if (response.statusCode != 401 ||
        !isAuthenticatedRequest ||
        path == '/auth/refresh') {
      return response;
    }

    final accessToken = await _refreshAccessToken();
    if (accessToken == null) {
      return response;
    }

    final retryHeaders = Map<String, String>.from(requestHeaders)
      ..['Authorization'] = 'Bearer $accessToken';
    return send(retryHeaders);
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      await _expireSession();
      return null;
    }

    try {
      final response = await _client.post(
        _uri('/auth/refresh'),
        headers: _headers(null),
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _expireSession();
        return null;
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        await _expireSession();
        return null;
      }

      final accessToken = json['access_token'];
      final nextRefreshToken = json['refresh_token'];
      if (accessToken is! String || nextRefreshToken is! String) {
        await _expireSession();
        return null;
      }

      await _tokenStorage.save(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
      return accessToken;
    } catch (_) {
      await _expireSession();
      return null;
    }
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clear();
    await onSessionExpired?.call();
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.bodyBytes.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const FormatException('서버 응답 형식이 올바르지 않습니다.');
    }

    if (decoded is Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        code: decoded['code']?.toString() ?? 'HTTP_ERROR',
        message: _errorMessage(decoded),
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_ERROR',
      message: '서버 요청에 실패했습니다.',
    );
  }

  String _errorMessage(Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic>) {
        return first['msg']?.toString() ?? '입력값을 확인해 주세요.';
      }
    }

    return '서버 요청에 실패했습니다.';
  }

  void close() {
    _client.close();
  }
}
