import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/data/auction_api.dart';
import 'package:frontend/features/auction/models/auction_page.dart';
import 'package:frontend/features/auction/models/auction_preview.dart';
import 'package:frontend/features/auction/models/auction_status.dart';
import 'package:frontend/features/auction/pages/auction_list_page.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';

void main() {
  testWidgets('새로고침 실패 시 기존 경매 목록을 유지한다', (tester) async {
    final gateway = _RefreshAuctionGateway();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AuctionListPage(gateway: gateway)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('기존 경매'), findsOneWidget);
    gateway.failRefresh = true;

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text('기존 경매'), findsOneWidget);
    expect(find.text('새로고침하지 못했어요.'), findsOneWidget);
  });
}

class _RefreshAuctionGateway extends AuctionApi {
  _RefreshAuctionGateway() : super(ApiClient(), AuthTokenStorage());

  bool failRefresh = false;

  @override
  Future<AuctionPage> listAuctions({int offset = 0, int limit = 20}) async {
    if (failRefresh) throw Exception('refresh failed');
    return const AuctionPage(
      items: [
        AuctionPreview(
          id: 1,
          title: '기존 경매',
          categoryName: '기타',
          status: AuctionStatus.completed,
          remainingTime: Duration.zero,
          currentPrice: '10,000원',
          bidCount: 1,
        ),
      ],
      total: 1,
      nextOffset: 1,
    );
  }
}
