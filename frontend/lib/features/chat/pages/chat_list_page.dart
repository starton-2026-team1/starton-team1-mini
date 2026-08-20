import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../controllers/chat_list_controller.dart';
import '../data/mock_chat_previews.dart';
import '../widgets/chat_filter_bar.dart';
import '../widgets/chat_list_item.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final ChatListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatListController(mockChatPreviews);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        titleSpacing: 20,
        title: const Text(
          '채팅',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 28),
            color: AppColors.textPrimary,
            tooltip: '알림',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 27),
            color: AppColors.textPrimary,
            tooltip: '설정',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final chats = _controller.visibleChats;
          return Column(
            children: [
              const SizedBox(height: 10),
              ChatFilterBar(
                selectedFilter: _controller.selectedFilter,
                onSelected: _controller.selectFilter,
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Expanded(
                child: chats.isEmpty
                    ? const Center(
                  child: Text('아직 채팅이 없어요.'),
                )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: chats.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 98,
                          color: AppColors.borderSubtle,
                        ),
                        itemBuilder: (_, index) =>
                            ChatListItem(chat: chats[index], onTap: () {}),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
