import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../../main_navigation/pages/main_navigation_page.dart';
import '../controllers/phone_auth_controller.dart';
import '../data/auth_api.dart';
import '../services/auth_token_storage.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({this.authApi, super.key});

  final AuthGateway? authApi;

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  ApiClient? _apiClient;
  late final PhoneAuthController _controller;

  @override
  void initState() {
    super.initState();

    final authApi = widget.authApi;

    if (authApi != null) {
      _controller = PhoneAuthController(authApi);
      return;
    }

    final apiClient = ApiClient();
    _apiClient = apiClient;
    _controller = PhoneAuthController(AuthApi(apiClient, AuthTokenStorage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _apiClient?.close();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = await _controller.submit();

    if (!mounted || session == null) {
      return;
    }

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainNavigationPage(userName: session.user.name),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final canSubmit = _controller.isValid && !_controller.isLoading;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              color: AppColors.black,
              iconSize: 28,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '휴대폰 정보를 입력해주세요.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller.phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: '01012345678',
                        hintStyle: const TextStyle(
                          color: AppColors.grey400,
                          fontSize: 18,
                        ),
                        errorText: _controller.errorMessage,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.black,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.black,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '휴대폰 번호가 변경되었나요?',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          '다음',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
