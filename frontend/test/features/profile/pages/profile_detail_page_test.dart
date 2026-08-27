import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/data/profile_api.dart';
import 'package:frontend/features/profile/pages/profile_detail_page.dart';
import 'package:frontend/features/product/data/mock_sales_management_items.dart';
import 'package:frontend/features/product/data/sales_management_api.dart';
import 'package:frontend/features/product/models/sales_management_item.dart';

class FakeProfileGateway implements ProfileGateway {
  @override
  Future<String> updateName(String name) async => name;
}

class FakeSalesManagementGateway implements SalesManagementGateway {
  @override
  Future<List<SalesManagementItem>> listMyProducts() async => [
    mockSalesManagementItems.first,
  ];

  @override
  Future<List<SalesManagementItem>> listMyBids() async => const [];
}

void main() {
  testWidgets('판매물품 카드를 누르면 판매관리 페이지로 이동한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileDetailPage(
          userId: 1,
          userName: '김주',
          mannerTemperature: 36.5,
          profileGateway: FakeProfileGateway(),
          onNameUpdated: (_) {},
          salesManagementGateway: FakeSalesManagementGateway(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final salesCard = find.text('판매물품 1');
    await tester.ensureVisible(salesCard);
    await tester.pumpAndSettle();
    await tester.tap(salesCard);
    await tester.pumpAndSettle();

    expect(find.text('판매/경매관리'), findsOneWidget);
    expect(find.text('경매중 1'), findsOneWidget);
    expect(find.text('판매중 0'), findsOneWidget);
    expect(find.text('완료 0'), findsOneWidget);
    expect(find.text('입찰내역 0'), findsOneWidget);
  });
}
