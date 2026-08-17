class ProductPreview {
  const ProductPreview({
    required this.title,
    required this.location,
    required this.time,
    required this.price,
    this.description,
    this.favoriteCount = 0,
    this.chatCount = 0,
    this.isPartTimeJob = false,
    this.isNeighborhoodBusiness = false,
    this.imageAsset,
  });

  final String title;
  final String location;
  final String time;
  final String price;
  final String? description;
  final int favoriteCount;
  final int chatCount;
  final bool isPartTimeJob;
  final bool isNeighborhoodBusiness;
  final String? imageAsset;
}

const mockProducts = [
  ProductPreview(
    title: '학원마케팅 제작및 데스크업무',
    location: '송도동',
    time: '6km · 알바',
    price: '월급 250만원',
    favoriteCount: 2,
    isPartTimeJob: true,
  ),
  ProductPreview(
    title: '노션 잘 다루시는 분',
    location: '송도동',
    time: '6km · 알바',
    price: '시급 12,000원',
    favoriteCount: 1,
    chatCount: 2,
    isPartTimeJob: true,
  ),
  ProductPreview(
    title: '버거킹',
    description: '콰치와퍼+불고기와퍼+와주+프라이L+너겟...',
    location: '',
    time: '43분 전',
    price: '3,000원',
    imageAsset: 'assets/image/burger.jpeg',
    isNeighborhoodBusiness: true,
  ),
  ProductPreview(
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    title: '갤럭시 버즈4',
    location: '구월3동',
    time: '4km · 12시간 전',
    price: '160,000원',
    favoriteCount: 2,
  ),
  ProductPreview(
    title: '버거킹',
    description: '콰치와퍼+불고기와퍼+와주+프라이L+너겟...',
    location: '',
    time: '43분 전',
    price: '3,000원',
    imageAsset: 'assets/image/burger.jpeg',
    isNeighborhoodBusiness: true,
  ),
  ProductPreview(
    title: '버거킹',
    description: '콰치와퍼+불고기와퍼+와주+프라이L+너겟...',
    location: '',
    time: '43분 전',
    price: '3,000원',
    imageAsset: 'assets/image/burger.jpeg',
    isNeighborhoodBusiness: true,
  ),
];
