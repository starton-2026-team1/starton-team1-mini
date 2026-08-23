import 'package:image_picker/image_picker.dart';

class AuctionCreateForm {
  const AuctionCreateForm({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.bidIncrement,
    required this.startsAt,
    required this.endsAt,
    required this.extensionCount,
    required this.imageFiles,
  });

  final int categoryId;
  final String title;
  final String description;
  final int startingPrice;
  final int bidIncrement;
  final DateTime startsAt;
  final DateTime endsAt;
  final int extensionCount;
  final List<XFile> imageFiles;
}
