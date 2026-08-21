import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/pages/sales_management_page.dart';

void main() {
  testWidgets('경매중, 판매중, 완료 필터를 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SalesManagementPage()));

    expect(find.text('판매/경매관리'), findsOneWidget);
    expect(find.text('경매중 1'), findsOneWidget);
    expect(find.text('판매중 1'), findsOneWidget);
    expect(find.text('완료 2'), findsOneWidget);
    expect(find.text('아이패드 프로 11인치'), findsOneWidget);
    expect(find.text('현재가 420,000원'), findsOneWidget);
    expect(find.text('00:12:34'), findsOneWidget);
    expect(find.text('끌어올리기'), findsOneWidget);
    expect(find.text('아디다스 집업'), findsNothing);
    expect(find.text('LG 노트북'), findsNothing);
    expect(find.text('숨김'), findsNothing);
    expect(find.text('글쓰기'), findsNothing);
  });

  testWidgets('완료 탭에 경매완료 상품의 최종 낙찰가와 입찰 수를 표시한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SalesManagementPage()));

    await tester.tap(find.text('완료 2'));
    await tester.pump();

    expect(find.text('맥북 에어 M2'), findsOneWidget);
    expect(find.text('최종 낙찰가 980,000원'), findsOneWidget);
    expect(find.text(' 16'), findsOneWidget);
    expect(find.text('후기 보내기'), findsNWidgets(2));
  });

  testWidgets('거래완료 필터를 선택할 수 있다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SalesManagementPage()));

    await tester.tap(find.text('완료 2'));
    await tester.pump();

    final chip = tester.widget<ChoiceChip>(
      find.ancestor(of: find.text('완료 2'), matching: find.byType(ChoiceChip)),
    );
    expect(chip.selected, isTrue);
    expect(find.text('LG 노트북'), findsOneWidget);
    expect(find.text('아이패드 프로 11인치'), findsNothing);
    expect(find.text('아디다스 집업'), findsNothing);
    expect(find.text('후기 보내기'), findsNWidgets(2));
  });
}
