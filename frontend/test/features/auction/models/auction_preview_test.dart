import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/models/auction_preview.dart';
import 'package:frontend/features/auction/models/auction_status.dart';

void main() {
  test('종료 및 취소 경매를 진행 중 경매 다음으로 정렬', () {
    final auctions = [
      _auction(1, AuctionStatus.cancelled),
      _auction(2, AuctionStatus.active),
      _auction(3, AuctionStatus.noBids),
      _auction(4, AuctionStatus.waiting),
      _auction(5, AuctionStatus.completed),
    ];

    final sorted = auctionsWithEndedLast(auctions);

    expect(sorted.map((auction) => auction.id), [2, 4, 1, 3, 5]);
  });
}

AuctionPreview _auction(int id, AuctionStatus status) {
  return AuctionPreview(
    id: id,
    title: '경매 $id',
    categoryName: '테스트',
    status: status,
    remainingTime: const Duration(hours: 1),
    currentPrice: '현재가 10,000원',
    bidCount: 0,
  );
}
