import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/chat/controllers/chat_list_controller.dart';
import 'package:frontend/features/chat/models/chat_filter.dart';
import 'package:frontend/features/chat/models/chat_preview.dart';

void main() {
  final chats = [
    ChatPreview(
      id: 1,
      otherUserId: 2,
      otherUserName: '판매자',
      lastMessage: '메시지',
      lastMessageAt: DateTime(2026, 8, 20),
      type: ChatType.auction,
      auctionId: 3,
    ),
    ChatPreview(
      id: 2,
      otherUserId: 4,
      otherUserName: '이웃',
      lastMessage: '메시지',
      lastMessageAt: DateTime(2026, 8, 20),
      type: ChatType.general,
    ),
  ];

  test('전체 필터는 모든 채팅을 표시한다', () {
    final controller = ChatListController(chats);
    addTearDown(controller.dispose);

    expect(controller.visibleChats, hasLength(2));
  });

  test('경매 필터는 경매 채팅만 표시한다', () {
    final controller = ChatListController(chats);
    addTearDown(controller.dispose);

    controller.selectFilter(ChatFilter.auction);

    expect(controller.visibleChats, hasLength(1));
    expect(controller.visibleChats.single.auctionId, 3);
  });
}
