import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auction/models/auction_draft.dart';

void main() {
  test('임시저장 데이터를 JSON으로 변환하고 복원한다', () {
    final draft = AuctionDraft(
      title: '자전거',
      description: '상태가 좋아요',
      startingPrice: '10000',
      bidIncrement: '1000',
      startsAt: DateTime(2026, 8, 20, 12),
      endsAt: DateTime(2026, 8, 20, 13),
      extensionCount: 3,
      imagePaths: const ['/tmp/bicycle.jpg'],
    );

    final restored = AuctionDraft.fromJson(draft.toJson());

    expect(restored.title, draft.title);
    expect(restored.startsAt, draft.startsAt);
    expect(restored.endsAt, draft.endsAt);
    expect(restored.extensionCount, 3);
    expect(restored.imagePaths, draft.imagePaths);
  });
}
