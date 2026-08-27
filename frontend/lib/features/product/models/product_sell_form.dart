import 'package:image_picker/image_picker.dart';

class ProductSellForm {
  const ProductSellForm({
    required this.imageFiles,
    required this.title,
    required this.description,
    required this.price,
    required this.place,
  });

  final List<XFile> imageFiles;
  final String title;
  final String description;
  final int price;
  final String place;
}
