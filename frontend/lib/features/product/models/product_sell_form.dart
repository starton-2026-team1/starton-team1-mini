class ProductSellForm {
  const ProductSellForm({
    required this.imagePaths,
    required this.title,
    required this.description,
    required this.price,
    required this.place,
  });

  final List<String> imagePaths;
  final String title;
  final String description;
  final int price;
  final String place;
}
