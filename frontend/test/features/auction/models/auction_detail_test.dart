import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/models/auction_detail.dart';

void main() {
  test('입찰이 없으면 시작가부터 입찰한다', () {
    const auction = AuctionDetail(
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
}
