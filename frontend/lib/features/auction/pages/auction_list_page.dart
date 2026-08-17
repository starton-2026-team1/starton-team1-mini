import 'package:flutter/material.dart';

import '../models/auction_preview.dart';
import '../widgets/auction_list_item.dart';

class AuctionListPage extends StatelessWidget {
  const AuctionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: mockAuctions.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFF0F1F3)),
      itemBuilder: (context, index) {
        return AuctionListItem(auction: mockAuctions[index]);
      },
    );
  }
}
