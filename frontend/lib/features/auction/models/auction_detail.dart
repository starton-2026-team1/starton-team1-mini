import 'auction_status.dart';

class AuctionBidPreview {
  const AuctionBidPreview({
    required this.bidderName,
    required this.amount,
    required this.timeLabel,
  });

  final String bidderName;
  final int amount;
  final String timeLabel;
}

class AuctionDetail {
  const AuctionDetail({
    required this.title,
    required this.category,
    required this.location,
    required this.sellerName,
    required this.mannerTemperature,
    required this.startPrice,
    required this.currentPrice,
    required this.minimumBidUnit,
    required this.remainingTime,
    required this.description,
    required this.favoriteCount,
    required this.bids,
    this.status = AuctionStatus.active,
    this.imageCount = 1,
  });

  final String title;
  final String category;
  final String location;
  final String sellerName;
  final double mannerTemperature;
  final int startPrice;
  final int currentPrice;
  final int minimumBidUnit;
  final Duration remainingTime;
  final String description;
  final int favoriteCount;
  final List<AuctionBidPreview> bids;
  final AuctionStatus status;
  final int imageCount;

  int get nextBidPrice =>
      bids.isEmpty ? startPrice : currentPrice + minimumBidUnit;
}

const mockAuctionDetail = AuctionDetail(
  title: '라이카 M6 클래식 필름 카메라',
  category: '디지털기기',
  location: '성수동',
  sellerName: '카메라좋아',
  mannerTemperature: 39.8,
  startPrice: 1000000,
  currentPrice: 1280000,
  minimumBidUnit: 20000,
  remainingTime: Duration(hours: 2, minutes: 14, seconds: 36),
  description:
      '필름 한 롤 테스트 촬영까지 완료했습니다. 노출계와 셔터 모두 정상 작동하며 '
      '생활 사용감 외에 큰 흠집은 없습니다. 본체, 스트랩, 바디캡, 정품 박스를 함께 드립니다.',
  favoriteCount: 18,
  imageCount: 4,
  bids: [
    AuctionBidPreview(bidderName: 'kim***', amount: 1280000, timeLabel: '방금 전'),
    AuctionBidPreview(bidderName: 'par***', amount: 1260000, timeLabel: '3분 전'),
    AuctionBidPreview(bidderName: 'lee***', amount: 1240000, timeLabel: '8분 전'),
    AuctionBidPreview(
      bidderName: 'cho***',
      amount: 1220000,
      timeLabel: '12분 전',
    ),
  ],
);
