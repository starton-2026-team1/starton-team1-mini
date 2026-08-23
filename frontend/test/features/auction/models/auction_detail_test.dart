import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/models/auction_detail.dart';
import 'package:frontend/features/auction/models/auction_status.dart';

void main() {
  test('입찰이 없으면 시작가부터 입찰한다', () {
    const auction = AuctionDetail(
      id: 1,
      title: '테스트 상품',
      category: '기타',
      location: '동네',
      sellerName: '판매자',
      mannerTemperature: 36.5,
      startPrice: 10000,
      currentPrice: 10000,
      minimumBidUnit: 1000,
      remainingTime: Duration(hours: 1),
      description: '상품 설명',
      favoriteCount: 0,
      bids: [],
    );

    expect(auction.nextBidPrice, 10000);
  });

  test('입찰이 있으면 현재가에 최소 입찰 단위를 더한다', () {
    const auction = AuctionDetail(
      id: 1,
      title: '테스트 상품',
      category: '기타',
      location: '동네',
      sellerName: '판매자',
      mannerTemperature: 36.5,
      startPrice: 10000,
      currentPrice: 12000,
      minimumBidUnit: 1000,
      remainingTime: Duration(hours: 1),
      description: '상품 설명',
      favoriteCount: 0,
      bids: [
        AuctionBidPreview(
          bidderName: 'bid***',
          amount: 12000,
          timeLabel: '방금 전',
        ),
      ],
    );

    expect(auction.nextBidPrice, 13000);
  });

  test('DB 경매 상태 문자열을 Flutter enum으로 변환한다', () {
    expect(AuctionStatus.fromApiValue('WAITING'), AuctionStatus.waiting);
    expect(AuctionStatus.fromApiValue('ACTIVE'), AuctionStatus.active);
    expect(AuctionStatus.fromApiValue('COMPLETED'), AuctionStatus.completed);
    expect(AuctionStatus.fromApiValue('NO_BIDS'), AuctionStatus.noBids);
    expect(AuctionStatus.fromApiValue('CANCELLED'), AuctionStatus.cancelled);
    expect(
      AuctionStatus.fromApiValue('TRADE_COMPLETED'),
      AuctionStatus.tradeCompleted,
    );
  });

  test('진행 중 상태에서만 입찰할 수 있다', () {
    expect(AuctionStatus.active.canBid, isTrue);
    for (final status in AuctionStatus.values.where(
      (status) => status != AuctionStatus.active,
    )) {
      expect(status.canBid, isFalse, reason: status.apiValue);
    }
  });

  test('상세 API 이미지 상대 경로를 서버 주소와 결합한다', () {
    final auction = AuctionDetail.fromJson({
      'id': 1,
      'title': '테스트 상품',
      'category_name': '기타',
      'seller_name': '판매자',
      'seller_id': 7,
      'status': 'ACTIVE',
      'start_price': 10000,
      'current_price': 10000,
      'minimum_bid_unit': 1000,
      'starts_at': '2026-08-23T10:00:00+09:00',
      'ends_at': '2099-08-24T10:00:00+09:00',
      'description': '상품 설명',
      'image_urls': ['/static/uploads/auction.jpg'],
      'bids': <Map<String, dynamic>>[],
    });

    expect(auction.imageUrls, hasLength(1));
    expect(auction.imageUrls.single, endsWith('/static/uploads/auction.jpg'));
    expect(auction.imageCount, 1);
  });

  test('종료된 상세 응답은 입찰을 비활성화하고 남은 시간을 0으로 처리한다', () {
    final auction = AuctionDetail.fromJson({
      'id': 1,
      'title': '종료 경매',
      'category_name': '기타',
      'seller_name': '판매자',
      'seller_id': 7,
      'status': 'NO_BIDS',
      'start_price': 10000,
      'current_price': 10000,
      'minimum_bid_unit': 1000,
      'starts_at': '2020-08-23T10:00:00+09:00',
      'ends_at': '2020-08-24T10:00:00+09:00',
      'description': '상품 설명',
      'image_urls': <String>[],
      'bids': <Map<String, dynamic>>[],
    });

    expect(auction.status, AuctionStatus.noBids);
    expect(auction.status.canBid, isFalse);
    expect(auction.remainingTime, Duration.zero);
  });
}
