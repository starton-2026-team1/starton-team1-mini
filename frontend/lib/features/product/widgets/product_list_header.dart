import 'package:flutter/material.dart';

class ProductListHeader extends StatelessWidget {
  const ProductListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 27),
            const SizedBox(width: 7),
            const Text(
              '대한민국',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 10),
            const Text(
              '전국',
              style: TextStyle(
                color: Color(0xFFB8BBC0),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_sharp, size: 31),
              visualDensity: VisualDensity.compact,
            ),
            Badge(
              smallSize: 8,
              backgroundColor: const Color(0xFFFF6F0F),
              offset: const Offset(-3, 4),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, size: 30),
                visualDensity: VisualDensity.compact,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, size: 30),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
