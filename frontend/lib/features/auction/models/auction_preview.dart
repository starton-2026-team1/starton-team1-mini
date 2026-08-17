enum AuctionStatus {
  waiting('경매 대기중'),
  active('경매 진행중'),
  completed('경매 완료');

  const AuctionStatus(this.label);

  final String label;
}

class AuctionPreview {
  const AuctionPreview({
    required this.title,
    required this.location,
    required this.status,
    required this.remainingTime,
    required this.currentPrice,
    required this.bidCount,
    this.favoriteCount = 0,
    this.imageAsset,
  });

  final String title;
  final String location;
  final AuctionStatus status;
  final Duration remainingTime;
  final String currentPrice;
  final int bidCount;
  final int favoriteCount;
  final String? imageAsset;

  String get remainingTimeLabel {
    if (status == AuctionStatus.completed || remainingTime <= Duration.zero) {
      return '0분 0초 남음';
    }

    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes.remainder(60);

    if (hours >= 1) {
      return '$hours시간 $minutes분 남음';
    }

    final seconds = remainingTime.inSeconds.remainder(60);
    return '$minutes분 $seconds초 남음';
  }
}

const mockAuctions = [
  AuctionPreview(
    title: '아이패드 프로 11인치',
    location: '송도동',
    status: AuctionStatus.active,
    remainingTime: Duration(minutes: 12, seconds: 34),
    currentPrice: '현재 420,000원',
    bidCount: 8,
    favoriteCount: 14,
  ),

];
