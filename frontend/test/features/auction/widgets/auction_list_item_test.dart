import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/models/auction_status.dart';
import 'package:frontend/features/auction/widgets/auction_list_item.dart';

void main() {
  test('24시간 미만 남은 시간은 시간 분 초로 표시한다', () {
    expect(
      auctionRemainingTimeLabel(
        AuctionStatus.active,
        const Duration(hours: 23, minutes: 59, seconds: 59),
      ),
      '23시간 59분 59초',
    );
  });

  test('24시간 이상 남은 시간은 일 시 분 초로 표시한다', () {
    expect(
      auctionRemainingTimeLabel(
        AuctionStatus.active,
        const Duration(days: 2, hours: 3, minutes: 4, seconds: 5),
      ),
      '2일 3시간 4분 5초',
    );
  });

  test('종료 상태 또는 남은 시간 0은 상태 문구를 표시한다', () {
    expect(
      auctionRemainingTimeLabel(AuctionStatus.active, Duration.zero),
      '경매 종료',
    );
    expect(
      auctionRemainingTimeLabel(
        AuctionStatus.completed,
        const Duration(hours: 1),
      ),
      AuctionStatus.completed.label,
    );
  });
}
