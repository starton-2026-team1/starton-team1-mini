import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/models/auction_update_message.dart';

void main() {
  test('자동 연장된 종료 시각과 남은 횟수를 실시간 메시지에서 변환', () {
    final message = AuctionUpdateMessage.fromJson({
      'type': 'bid_update',
      'current_price': 12000,
      'next_bid_price': 13000,
      'ends_at': '2026-08-24T10:05:00+09:00',
      'remaining_extension_count': 1,
      'latest_bid': {
        'bidder_name': '입***',
        'amount': 12000,
        'created_at': DateTime.now().toIso8601String(),
      },
    });

    expect(message.endsAt.toUtc(), DateTime.utc(2026, 8, 24, 1, 5));
    expect(message.remainingExtensionCount, 1);
  });
}
