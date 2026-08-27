import 'package:flutter/foundation.dart';

import '../models/chat_filter.dart';
import '../models/chat_preview.dart';

class ChatListController extends ChangeNotifier {
  ChatListController(this._chats);

  final List<ChatPreview> _chats;
  ChatFilter selectedFilter = ChatFilter.all;

  List<ChatPreview> get visibleChats {
    return switch (selectedFilter) {
      ChatFilter.all => List.unmodifiable(_chats),
      ChatFilter.auction => List.unmodifiable(
        _chats.where((chat) => chat.isAuction),
      ),
    };
  }

  void selectFilter(ChatFilter filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    notifyListeners();
  }
}
