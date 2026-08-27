import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/models/product_sell_draft.dart';
import 'package:frontend/features/product/pages/product_sell_page.dart';
import 'package:frontend/features/product/services/product_sell_draft_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('내 물건 팔기 폼을 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductSellPage()));

    expect(find.text('전국에 올리기'), findsOneWidget);
    expect(find.text('제목'), findsOneWidget);
    expect(find.text('자세한 설명'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('가격을 입력해주세요.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('가격을 입력해주세요.'), findsOneWidget);
    expect(find.text('나눔하기'), findsNothing);
    expect(find.text('가격 제안 받기'), findsNothing);
    expect(find.text('자주 쓰는 문구'), findsNothing);
    expect(find.text('작성 완료'), findsOneWidget);
  });

  testWidgets('입력값이 변경되면 임시저장 버튼이 활성화되고 저장한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductSellPage()));
    await tester.pumpAndSettle();

    TextButton saveButton = tester.widget(
      find.widgetWithText(TextButton, '임시저장'),
    );
    expect(saveButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '자전거');
    await tester.pump();

    saveButton = tester.widget(find.widgetWithText(TextButton, '임시저장'));
    expect(saveButton.onPressed, isNotNull);

    await tester.tap(find.text('임시저장'));
    await tester.pumpAndSettle();

    final ProductSellDraft? draft = await ProductSellDraftStorage().load();
    expect(draft, isNotNull);
    expect(draft!.title, '자전거');
  });
}
