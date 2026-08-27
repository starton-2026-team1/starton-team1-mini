class ProductSellDraft {
  const ProductSellDraft({
    required this.title,
    required this.description,
    required this.price,
    required this.place,
    this.imagePaths = const [],
  });

  final String title;
  final String description;
  final String price;
  final String place;
  final List<String> imagePaths;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'place': place,
      'imagePaths': imagePaths,
    };
  }

  factory ProductSellDraft.fromJson(Map<String, dynamic> json) {
    return ProductSellDraft(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as String? ?? '',
      place: json['place'] as String? ?? '',
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}
