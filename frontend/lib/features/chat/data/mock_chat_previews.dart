import '../models/chat_preview.dart';

final mockChatPreviews = [
  ChatPreview(
    id: 1,
    otherUserId: 12,
    otherUserName: '사람1',
    lastMessage: '거래 가능한 시간을 알려주세요.',
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 8)),
    type: ChatType.auction,
    unreadCount: 2,
    productId: 101,
    auctionId: 31,
    productTitle: '아이패드 프로 11인치',
  ),
  ChatPreview(
    id: 2,
    otherUserId: 18,
    otherUserName: '사람2',
    lastMessage: '낙찰 확인했습니다. 감사합니다.',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
    type: ChatType.auction,
    productId: 104,
    auctionId: 36,
    productTitle: '빈티지 오디오',
  ),
  ChatPreview(
    id: 3,
    otherUserId: 27,
    otherUserName: '이웃',
    lastMessage: '내일 저녁에 거래 가능할까요?',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
    type: ChatType.general,
    unreadCount: 1,
    productId: 108,
    productTitle: '원목 테이블',
  ),
];
