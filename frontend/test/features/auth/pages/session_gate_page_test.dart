import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/models/auth_session.dart';
import 'package:frontend/features/auth/models/auth_tokens.dart';
import 'package:frontend/features/auth/models/auth_user.dart';
import 'package:frontend/features/auth/pages/session_gate_page.dart';
import 'package:frontend/features/auth/pages/welcome_page.dart';
import 'package:frontend/features/main_navigation/pages/main_navigation_page.dart';

void main() {
  testWidgets('저장된 세션이 유효하면 메인 화면을 표시한다', (tester) async {
    final gateway = _SessionAuthGateway(
      const AuthUser(id: 7, phoneNumber: '01012345678', name: '테스트 사용자'),
    );

    await tester.pumpWidget(
      MaterialApp(home: SessionGatePage(authGateway: gateway)),
    );
    await tester.pump();

    expect(find.byType(MainNavigationPage), findsOneWidget);
    final page = tester.widget<MainNavigationPage>(
      find.byType(MainNavigationPage),
    );
    expect(page.userId, 7);
    expect(page.userName, '테스트 사용자');
  });

  testWidgets('저장된 세션을 확인하지 못하면 시작 화면을 표시한다', (tester) async {
    final gateway = _SessionAuthGateway.error();

    await tester.pumpWidget(
      MaterialApp(home: SessionGatePage(authGateway: gateway)),
    );
    await tester.pump();

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}

class _SessionAuthGateway implements AuthGateway {
  _SessionAuthGateway(this._user) : _error = null;

  _SessionAuthGateway.error()
    : _user = null,
      _error = Exception('unauthorized');

  final AuthUser? _user;
  final Object? _error;

  @override
  Future<AuthUser> getSession() async {
    if (_error case final error?) {
      throw error;
    }
    return _user!;
  }

  @override
  Future<AuthSession> login(String phoneNumber) => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<AuthTokens> refresh() => throw UnimplementedError();
}
