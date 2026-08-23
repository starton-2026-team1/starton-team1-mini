import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/data/mock_sales_management_items.dart';
import 'package:frontend/features/product/data/sales_management_api.dart';
import 'package:frontend/features/product/models/sales_management_item.dart';
import 'package:frontend/features/product/pages/sales_management_page.dart';

class FakeSalesManagementGateway implements SalesManagementGateway {
  FakeSalesManagementGateway({
    this.items = mockSalesManagementItems,
    this.error,
  });

  final List<SalesManagementItem> items;
  final Object? error;
  int callCount = 0;

  @override
  Future<List<SalesManagementItem>> listMyProducts() async {
    callCount++;
    if (error != null) throw error!;
    return items;
  }
}

Widget buildPage({
  SalesManagementGateway? gateway,
  Widget Function(int)? auctionDetailBuilder,
  Widget Function(SalesManagementItem)? productDetailBuilder,
}) {
  return MaterialApp(
    home: SalesManagementPage(
      gateway: gateway ?? FakeSalesManagementGateway(),
      auctionDetailBuilder: auctionDetailBuilder,
      productDetailBuilder: productDetailBuilder,
    ),
  );
}

void main() {
  testWidgets('경매중, 판매중, 완료 필터를 표시한다', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('완료 2'));
    await tester.pump();

    expect(find.text('맥북 에어 M2'), findsOneWidget);
    expect(find.text('최종 낙찰가 980,000원'), findsOneWidget);
    expect(find.text(' 16'), findsOneWidget);
    expect(find.text('후기 보내기'), findsNWidgets(2));
  });

  testWidgets('거래완료 필터를 선택할 수 있다', (tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

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

  testWidgets('조회 결과가 없으면 빈 상태를 표시한다', (tester) async {
    await tester.pumpWidget(
      buildPage(gateway: FakeSalesManagementGateway(items: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('해당하는 판매 상품이 없어요.'), findsOneWidget);
  });

  testWidgets('조회 실패 시 다시 시도 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(
      buildPage(gateway: FakeSalesManagementGateway(error: Exception())),
    );
    await tester.pumpAndSettle();

    expect(find.text('판매 상품을 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('경매 카드는 auctionId로 경매 상세를 연다', (tester) async {
    int? selectedAuctionId;
    await tester.pumpWidget(
      buildPage(
        auctionDetailBuilder: (auctionId) {
          selectedAuctionId = auctionId;
          return const Scaffold(body: Text('경매 상세 테스트'));
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('아이패드 프로 11인치'));
    await tester.pumpAndSettle();

    expect(selectedAuctionId, 3);
    expect(find.text('경매 상세 테스트'), findsOneWidget);
  });

  testWidgets('일반 판매 카드는 상품 상세를 열고 복귀 시 다시 조회한다', (tester) async {
    final gateway = FakeSalesManagementGateway();
    int? selectedProductId;
    await tester.pumpWidget(
      buildPage(
        gateway: gateway,
        productDetailBuilder: (item) {
          selectedProductId = item.id;
          return const Scaffold(body: Text('상품 상세 테스트'));
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('판매중 1'));
    await tester.pump();

    await tester.tap(find.text('아디다스 집업'));
    await tester.pumpAndSettle();

    expect(selectedProductId, 1);
    expect(find.text('상품 상세 테스트'), findsOneWidget);

    Navigator.of(tester.element(find.text('상품 상세 테스트'))).pop();
    await tester.pumpAndSettle();

    expect(gateway.callCount, 2);
  });
}
