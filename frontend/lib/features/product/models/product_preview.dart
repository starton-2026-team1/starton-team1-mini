import 'package:frontend/shared/network/api_config.dart';

import 'product_category.dart';

class ProductPreview {
  const ProductPreview({
    this.id = 0,
    required this.category,
    required this.title,
    required this.location,
    required this.time,
    required this.price,
    this.description,
    this.sellerName = '판매자',
    this.imageUrls = const [],
    this.favoriteCount = 0,
    this.chatCount = 0,
    this.isPartTimeJob = false,
    this.isNeighborhoodBusiness = false,
    this.imageAsset,
  });

  final int id;
  final ProductCategory category;
  final String title;
  final String location;
  final String time;
  final String price;
  final String? description;
  final String sellerName;
  final List<String> imageUrls;
  final int favoriteCount;
  final int chatCount;
  final bool isPartTimeJob;
  final bool isNeighborhoodBusiness;
  final String? imageAsset;

  String? get primaryImageUrl => imageUrls.isEmpty ? null : imageUrls.first;

  // 일반 상품 목록 API 응답을 기존 카드 표시 모델로 변환한다.
  factory ProductPreview.fromJson(Map<String, dynamic> json, {DateTime? now}) {
    final createdAt = DateTime.parse(json['created_at'] as String).toLocal();
    final currentTime = now ?? DateTime.now();
    final fixedPrice = json['fixed_price'] as Map<String, dynamic>;
    return ProductPreview(
      id: (json['id'] as num).toInt(),
      category: ProductCategory.used,
      title: json['title'] as String,
      description: json['description'] as String?,
      sellerName: json['seller_name'] as String? ?? '판매자',
      imageUrls: (json['image_urls'] as List<dynamic>? ?? const [])
          .map((path) => _resolveImageUrl(path as String))
          .toList(),
      location: '전국',
      time: _elapsedTimeLabel(createdAt, currentTime),
      price: _formatPrice((fixedPrice['price'] as num).toInt()),
    );
  }
}

String _resolveImageUrl(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  return '${ApiConfig.mediaBaseUrl}${path.startsWith('/') ? '' : '/'}$path';
}

String _elapsedTimeLabel(DateTime createdAt, DateTime now) {
  final elapsed = now.difference(createdAt);
  if (elapsed.inMinutes < 1) return '방금 전';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}분 전';
  if (elapsed.inDays < 1) return '${elapsed.inHours}시간 전';
  return '${elapsed.inDays}일 전';
}

String _formatPrice(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return '$buffer원';
}

const mockProducts = [
  ProductPreview(
    category: ProductCategory.partTimeJob,
    title: '학원마케팅 제작및 데스크업무',
    location: '송도동',
    time: '6km · 알바',
    price: '월급 250만원',
    favoriteCount: 2,
    isPartTimeJob: true,
  ),
  ProductPreview(
    category: ProductCategory.partTimeJob,
    title: '노션 잘 다루시는 분',
    location: '송도동',
    time: '6km · 알바',
    price: '시급 12,000원',
    favoriteCount: 1,
    chatCount: 2,
    isPartTimeJob: true,
  ),
  ProductPreview(
    category: ProductCategory.used,
    title: '버거킹',
    description: '콰치와퍼+불고기와퍼+와주+프라이L+너겟...',
    location: '',
    time: '43분 전',
    price: '3,000원',
    imageAsset: 'assets/image/burger.jpeg',
    isNeighborhoodBusiness: true,
  ),
  ProductPreview(
    category: ProductCategory.used,
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    category: ProductCategory.used,
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    category: ProductCategory.realEstate,
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    category: ProductCategory.realEstate,
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    category: ProductCategory.used,
    title: '버거킹',
    description: '콰치와퍼+불고기와퍼+와주+프라이L+너겟...',
    location: '',
    time: '43분 전',
    price: '3,000원',
    imageAsset: 'assets/image/burger.jpeg',
    isNeighborhoodBusiness: true,
  ),
  ProductPreview(
    category: ProductCategory.used,
    title: '버거킹',
    description: '콰치와퍼+불고기와퍼+와주+프라이L+너겟...',
    location: '',
    time: '43분 전',
    price: '3,000원',
    imageAsset: 'assets/image/burger.jpeg',
    isNeighborhoodBusiness: true,
  ),
];
