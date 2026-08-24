import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/product/models/product_category.dart';
import 'package:frontend/features/product/models/product_preview.dart';
import 'package:frontend/shared/network/api_config.dart';

void main() {
  test('일반 상품 목록 API 응답을 카드 모델로 변환한다', () {
    final product = ProductPreview.fromJson({
      'id': 41,
      'title': '테스트 상품',
      'description': '상품 설명',
      'seller_name': '당근이',
      'image_urls': ['/static/uploads/product.jpg'],
      'created_at': '2026-08-23T10:00:00',
      'fixed_price': {'price': 12000},
    }, now: DateTime(2026, 8, 23, 12));

    expect(product.id, 41);
    expect(product.category, ProductCategory.used);
    expect(product.title, '테스트 상품');
    expect(product.sellerName, '당근이');
    expect(product.imageUrls, [
      '${ApiConfig.mediaBaseUrl}/static/uploads/product.jpg',
    ]);
    expect(product.time, '2시간 전');
    expect(product.price, '12,000원');
  });
}
