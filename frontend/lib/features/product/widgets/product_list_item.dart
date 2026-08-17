import 'package:flutter/material.dart';

import '../models/product_preview.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({required this.product, super.key});

  final ProductPreview product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(product: product),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.more_vert,
                        color: Color(0xFF969A9F),
                        size: 22,
                      ),
                    ],
                  ),
                  Text(
                    [
                      product.location,
                      product.time,
                    ].where((value) => value.isNotEmpty).join(' · '),
                    style: const TextStyle(
                      color: Color(0xFF969A9F),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.isNeighborhoodBusiness) ...[
                    const SizedBox(height: 7),
                    const _NeighborhoodBusinessBadge(),
                  ],
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _ProductCounts(product: product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductPreview product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: product.isPartTimeJob
            ? const Color(0xFFFAFAFB)
            : const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE3E4E7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageAsset == null
          ? Icon(
              product.isPartTimeJob
                  ? Icons.person
                  : Icons.image_search,
              color: const Color(0xFFDDDDE3),
              size: 70,
            )
          : Image.asset(product.imageAsset!, fit: BoxFit.cover),
    );
  }
}

class _ProductCounts extends StatelessWidget {
  const _ProductCounts({required this.product});

  final ProductPreview product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (product.chatCount > 0) ...[
          const Icon(Icons.group_rounded, size: 18, color: Color(0xFFD2D3D7)),
          const SizedBox(width: 2),
          Text(
            '${product.chatCount}',
            style: const TextStyle(color: Color(0xFF969A9F), fontSize: 11),
          ),
          const SizedBox(width: 6),
        ],
        if (product.favoriteCount > 0) ...[
          const Icon(Icons.favorite, size: 19, color: Color(0xFFD2D3D7)),
          const SizedBox(width: 3),
          Text(
            '${product.favoriteCount}',
            style: const TextStyle(color: Color(0xFF969A9F), fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _NeighborhoodBusinessBadge extends StatelessWidget {
  const _NeighborhoodBusinessBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          '바로구매',
          style: TextStyle(
            color: Color(0xFFFF6F0F),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
