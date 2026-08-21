import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/pages/sales_management_page.dart';

void main() {
  testWidgets('판매중과 거래완료 필터만 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SalesManagementPage()));

    expect(find.text('판매관리'), findsOneWidget);
    expect(find.text('판매중 0'), findsOneWidget);
    expect(find.text('거래완료 0'), findsOneWidget);
    expect(find.text('숨김'), findsNothing);
    expect(find.text('글쓰기'), findsNothing);
  });

  testWidgets('거래완료 필터를 선택할 수 있다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SalesManagementPage()));

    await tester.tap(find.text('거래완료 0'));
    await tester.pump();

    final chip = tester.widget<ChoiceChip>(
      find.ancestor(of: find.text('거래완료 0'), matching: find.byType(ChoiceChip)),
    );
    expect(chip.selected, isTrue);
  });
}
