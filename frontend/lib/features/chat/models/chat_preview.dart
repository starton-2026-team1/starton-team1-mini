enum ChatType { general, auction }

class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.type,
    this.unreadCount = 0,
    this.productId,
    this.auctionId,
    this.productTitle,
    this.productImageAsset,
  });

  final int id;
  final int otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final ChatType type;
  final int unreadCount;
  final int? productId;
  final int? auctionId;
  final String? productTitle;
  final String? productImageAsset;

  bool get isAuction => type == ChatType.auction;
}
