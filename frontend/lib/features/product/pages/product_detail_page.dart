import 'package:flutter/material.dart';

import '../models/product_preview.dart';

// 매너온도에 따라 이모티콘을 반환하는 함수
String getMannerEmoji(double temperature) {
  if (temperature >= 50) return '😍';
  if (temperature >= 40) return '😄';
  if (temperature >= 30) return '😊';
  return '😐';
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductPreview product;

  @override
  Widget build(BuildContext context) {
    // 현재는 테스트용 매너온도
    // 나중에 DB/API 연결 후 실제 판매자의 매너온도로 변경
    const double mannerTemperature = 39.8;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // 스크롤되는 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================
                    // 1. 상품 이미지 영역
                    // =========================================

                    SizedBox(
                      height: 330,
                      width: double.infinity,

                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 상품 이미지
                          Container(
                            color: const Color(0xFFF2F3F5),

                            child: product.imageAsset == null
                                ? const Icon(
                                    Icons.image_outlined,
                                    size: 80,
                                    color: Color(0xFFD2D3D7),
                                  )
                                : Image.asset(
                                    product.imageAsset!,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          // 뒤로가기 버튼
                          Positioned(
                            top: 8,
                            left: 8,

                            child: IconButton(
                              onPressed: () {
                                Navigator.maybePop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 22,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // 공유 버튼
                          Positioned(
                            top: 8,
                            right: 48,

                            child: IconButton(
                              onPressed: () {},

                              icon: const Icon(
                                Icons.share_outlined,
                                size: 23,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // 더보기 버튼
                          Positioned(
                            top: 8,
                            right: 8,

                            child: IconButton(
                              onPressed: () {},

                              icon: const Icon(
                                Icons.more_vert,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================================
                    // 2. 판매자 정보 영역
                    // =========================================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),

                      child: Row(
                        children: [
                          // 판매자 프로필 사진
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFE9EAEC),

                            child: Icon(
                              Icons.person,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 10),

                          // 판매자 이름 + 위치
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // 임시 판매자 이름
                                // 나중에 DB/API 데이터로 변경
                                const Text(
                                  '구름베리',

                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                // 판매자 위치
                                Text(
                                  product.location.isEmpty
                                      ? '동네 정보 없음'
                                      : product.location,

                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF868B94),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // =====================================
                          // 매너온도
                          // =====================================
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,

                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  // 매너온도 숫자
                                  Text(
                                    '${mannerTemperature.toStringAsFixed(1)}°C',

                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF6F0F),
                                    ),
                                  ),

                                  const SizedBox(width: 4),

                                  // 매너온도에 따라 바뀌는 이모티콘
                                  Text(
                                    getMannerEmoji(mannerTemperature),

                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 2),

                              const Text(
                                '매너온도',

                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF868B94),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 판매자 영역과 상품 영역 구분선
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF2F3F5),
                    ),

                    // =========================================
                    // 3. 상품 상세 정보
                    // =========================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // 상품명
                          Text(
                            product.title,

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 7),

                          // 상품 가격
                          Row(
                            children: [
                              Text(
                                product.price,

                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(width: 4),

                              // 당근 로고 표시 + pay
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'lib/assets/image/logo.png',
                                    width: 14,
                                    height: 14,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 1),
                                  const Text(
                                    'pay',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF6F0F),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // 카테고리 + 시간
                          Text(
                            '디지털기기 · ${product.time}',

                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF868B94),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 상품 설명
                          Text(
                            product.description ?? '상품 설명이 없습니다.',

                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: Color(0xFF212124),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================================
            // 4. 하단 고정 영역
            // =========================================
            Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),

              decoration: const BoxDecoration(
                color: Colors.white,

                border: Border(top: BorderSide(color: Color(0xFFF2F3F5))),
              ),

              child: Row(
                children: [
                  // 찜 버튼
                  IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.favorite_border,
                      size: 27,
                      color: Color(0xFFB0B3B8),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // 채팅하기 버튼
                  Expanded(
                    child: SizedBox(
                      height: 48,

                      child: ElevatedButton(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F0F),
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),

                        child: const Text(
                          '채팅하기',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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
