import 'package:flutter/material.dart';
import 'package:frontend/shared/network/api_exception.dart';

import '../data/auth_api.dart';
import '../models/auth_session.dart';

class PhoneAuthController extends ChangeNotifier {
  PhoneAuthController(this._authApi) {
    phoneController.addListener(_handlePhoneChanged);
  }

  final AuthGateway _authApi;
  final phoneController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  String get normalizedPhoneNumber {
    return phoneController.text.replaceAll(RegExp(r'\D'), '');
  }

  bool get isValid {
    return RegExp(r'^010\d{8}$').hasMatch(normalizedPhoneNumber);
  }

  Future<AuthSession?> submit() async {
    if (!isValid) {
      errorMessage = '010으로 시작하는 휴대폰 번호 11자리를 입력해 주세요.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await _authApi.login(normalizedPhoneNumber);
    } on ApiException catch (error) {
      errorMessage = error.message;
      return null;
    } on Object {
      errorMessage = '서버에 연결할 수 없습니다.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _handlePhoneChanged() {
    if (errorMessage != null) {
      errorMessage = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.removeListener(_handlePhoneChanged);
    phoneController.dispose();
    super.dispose();
  }
}
