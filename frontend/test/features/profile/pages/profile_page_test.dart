import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/data/profile_api.dart';
import 'package:frontend/features/profile/pages/profile_page.dart';

class FakeProfileGateway implements ProfileGateway {
  @override
  Future<String> updateName(String name) async => name;
}

Widget buildProfilePage({
  String userName = '사용자',
  ValueChanged<dynamic>? onMenuTap,
  Future<void> Function()? onLogout,
}) {
  return ProfilePage(
    userId: 1,
    userName: userName,
    profileGateway: FakeProfileGateway(),
    onNameUpdated: (_) {},
    onMenuTap: onMenuTap,
    onLogout: onLogout,
  );
}

void main() {
  testWidgets('로그인 사용자 이름과 마이페이지 메뉴를 보여준다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: buildProfilePage(userName: '김주')),
      ),
    );

    expect(find.text('김주'), findsOneWidget);
    expect(find.text('37.9°C'), findsOneWidget);
    expect(find.text('관심목록'), findsWidgets);
    expect(find.text('판매/경매관리'), findsOneWidget);
    expect(find.text('구매내역'), findsOneWidget);
  });

  testWidgets('메뉴를 누르면 routeKey를 전달한다', (tester) async {
    String? selectedRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildProfilePage(
            onMenuTap: (item) => selectedRoute = item.routeKey,
          ),
        ),
      ),
    );

    await tester.tap(find.text('판매/경매관리'));

    expect(selectedRoute, 'sales');
  });

  testWidgets('로그아웃 버튼이 로그아웃 콜백을 호출한다', (tester) async {
    var logoutCount = 0;
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildProfilePage(onLogout: () async => logoutCount++),
        ),
      ),
    );

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    expect(logoutCount, 1);
  });
}
