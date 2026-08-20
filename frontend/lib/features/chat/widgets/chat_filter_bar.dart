import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/app_filter_chip_bar.dart';

import '../models/chat_filter.dart';

class ChatFilterBar extends StatelessWidget {
  const ChatFilterBar({
    required this.selectedFilter,
    required this.onSelected,
    super.key,
  });

  final ChatFilter selectedFilter;
  final ValueChanged<ChatFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppFilterChipBar<ChatFilter>(
      items: ChatFilter.values,
      selectedItem: selectedFilter,
      labelBuilder: (filter) => filter.label,
      onSelected: onSelected,
    );
  }
}
