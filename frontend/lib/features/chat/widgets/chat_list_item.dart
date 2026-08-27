import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../models/chat_preview.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({required this.chat, required this.onTap, super.key});

  final ChatPreview chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _ChatThumbnail(chat: chat),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          chat.otherUserName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: const TextStyle(
                          color: AppColors.textPlaceholder,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (chat.productTitle != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (chat.isAuction) ...[
                          const Icon(
                            Icons.gavel_outlined,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            chat.productTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(width: 12),
              _UnreadBadge(count: chat.unreadCount),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    if (date == today) {
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    final days = today.difference(date).inDays;
    if (days == 1) return '어제';
    return '${value.month}.${value.day}';
  }
}

class _ChatThumbnail extends StatelessWidget {
  const _ChatThumbnail({required this.chat});

  final ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: chat.isAuction
            ? AppColors.primaryContainer
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: chat.productImageAsset == null
          ? Icon(
              chat.isAuction ? Icons.gavel_outlined : Icons.sell_outlined,
              color: chat.isAuction
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 30,
            )
          : Image.asset(chat.productImageAsset!, fit: BoxFit.cover),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
