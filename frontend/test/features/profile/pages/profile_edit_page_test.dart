import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/data/profile_api.dart';
import 'package:frontend/features/profile/pages/profile_edit_page.dart';

class RecordingProfileGateway implements ProfileGateway {
  String? requestedName;

  @override
  Future<String> updateName(String name) async {
    requestedName = name;
    return name;
  }
}

void main() {
  testWidgets('변경한 닉네임을 API에 전달한다', (tester) async {
    final gateway = RecordingProfileGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileEditPage(userName: '김주', profileGateway: gateway),
      ),
    );

    await tester.enterText(find.byType(TextField), '당근이');
    await tester.pump();
    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '완료'),
    );
    button.onPressed!();
    await tester.pumpAndSettle();

    expect(gateway.requestedName, '당근이');
  });

  testWidgets('닉네임이 변경되지 않으면 완료 버튼이 비활성화된다', (tester) async {
    final gateway = RecordingProfileGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileEditPage(userName: '김주', profileGateway: gateway),
      ),
    );

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '완료'),
    );

    expect(button.onPressed, isNull);
  });
}
