import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product_sell_form.dart';

enum ProductSellField { images, title, description, price, place }

class ProductSellController extends ChangeNotifier {
  ProductSellController() {
    for (final controller in _textControllers) {
      controller.addListener(_handleChanged);
    }
  }

  static final priceFormatter = FilteringTextInputFormatter.digitsOnly;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final placeController = TextEditingController();
  final Map<ProductSellField, String> errors = {};

  List<String> imagePaths = [];
  bool isDirty = false;
  List<TextEditingController> get _textControllers => [
    titleController,
    descriptionController,
    priceController,
    placeController,
  ];

  void setImages(List<String> paths) {
    imagePaths = paths;
    clearError(ProductSellField.images);
    isDirty = true;
    notifyListeners();
  }

  void clearError(ProductSellField field) {
    if (errors.remove(field) != null) {
      notifyListeners();
    }
  }

  void markSaved() {
    if (!isDirty) {
      return;
    }
    isDirty = false;
    notifyListeners();
  }

  ProductSellForm? buildForm() {
    errors.clear();

    if (imagePaths.isEmpty) {
      errors[ProductSellField.images] = '사진을 1장 이상 추가해 주세요.';
    }
    if (titleController.text.trim().isEmpty) {
      errors[ProductSellField.title] = '제목을 입력해 주세요.';
    }
    if (descriptionController.text.trim().isEmpty) {
      errors[ProductSellField.description] = '자세한 설명을 입력해 주세요.';
    }
    final price = int.tryParse(priceController.text);
    if (price == null || price <= 0) {
      errors[ProductSellField.price] = '가격을 입력해 주세요.';
    }
    if (placeController.text.trim().isEmpty) {
      errors[ProductSellField.place] = '거래 희망 장소를 입력해 주세요.';
    }

    notifyListeners();
    if (errors.isNotEmpty) {
      return null;
    }

    return ProductSellForm(
      imagePaths: List.unmodifiable(imagePaths),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      price: price!,
      place: placeController.text.trim(),
    );
  }

  void _handleChanged() {
    isDirty = true;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.removeListener(_handleChanged);
      controller.dispose();
    }
    super.dispose();
  }
}
