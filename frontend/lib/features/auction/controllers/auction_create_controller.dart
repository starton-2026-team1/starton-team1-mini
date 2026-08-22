import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auction_create_form.dart';

enum AuctionCreateField {
  images,
  title,
  description,
  startingPrice,
  bidIncrement,
  startsAt,
  endsAt,
}

class AuctionCreateController extends ChangeNotifier {
  AuctionCreateController() {
    for (final controller in _textControllers) {
      controller.addListener(_markDirty);
    }
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final startingPriceController = TextEditingController();
  final bidIncrementController = TextEditingController();

  final now = DateTime.now();

  DateTime? startsAt;
  DateTime? endsAt;
  int extensionCount = 0;
  int categoryId = 1;
  bool isDirty = false;
  final Map<AuctionCreateField, String> errors = {};
  List<String> imagePaths = const [];

  List<TextEditingController> get _textControllers => [
    titleController,
    descriptionController,
    startingPriceController,
    bidIncrementController,
  ];

  static final priceFormatter = FilteringTextInputFormatter.digitsOnly;

  void setStartsAt(DateTime value) {
    startsAt = value;
    if (endsAt != null && !endsAt!.isAfter(value)) {
      endsAt = value.add(const Duration(hours: 1));
    }
    errors.remove(AuctionCreateField.startsAt);
    errors.remove(AuctionCreateField.endsAt);
    isDirty = true;
    notifyListeners();
  }

  void setEndsAt(DateTime value) {
    endsAt = value;
    errors.remove(AuctionCreateField.endsAt);
    isDirty = true;
    notifyListeners();
  }

  void setExtensionCount(int value) {
    extensionCount = value;
    isDirty = true;
    notifyListeners();
  }

  void setImagePaths(List<String> value) {
    imagePaths = List.unmodifiable(value);
    errors.remove(AuctionCreateField.images);
    isDirty = true;
    notifyListeners();
  }

  void clearError(AuctionCreateField field) {
    if (errors.remove(field) != null) notifyListeners();
  }

  void markSaved() {
    if (!isDirty) return;
    isDirty = false;
    notifyListeners();
  }

  void _markDirty() {
    if (isDirty) return;
    isDirty = true;
    notifyListeners();
  }

  String? validate() {
    errors.clear();
    if (titleController.text.trim().isEmpty) {
      errors[AuctionCreateField.title] = '제목을 입력해 주세요.';
    }
    if (descriptionController.text.trim().isEmpty) {
      errors[AuctionCreateField.description] = '상세 내용을 입력해 주세요.';
    }
    final startingPrice = int.tryParse(startingPriceController.text);
    if (startingPrice == null || startingPrice <= 0) {
      errors[AuctionCreateField.startingPrice] = '시작 가격을 입력해 주세요.';
    }
    final bidIncrement = int.tryParse(bidIncrementController.text);
    if (bidIncrement == null || bidIncrement <= 0) {
      errors[AuctionCreateField.bidIncrement] = '최소 입찰 단위를 입력해 주세요.';
    }
    if (startsAt == null) {
      errors[AuctionCreateField.startsAt] = '시작 시간을 선택해 주세요.';
    } else if (!startsAt!.isAfter(now)) {
      errors[AuctionCreateField.startsAt] = '시작 시간은 현재 시간보다 늦어야 해요.';
    }
    if (endsAt == null) {
      errors[AuctionCreateField.endsAt] = '끝나는 시간을 선택해 주세요.';
    } else if (startsAt != null && !endsAt!.isAfter(startsAt!)) {
      errors[AuctionCreateField.endsAt] = '종료 시간은 시작 시간보다 늦어야 해요.';
    }
    if (imagePaths.isEmpty) {
      errors[AuctionCreateField.images] = '상품 사진을 한 장 이상 등록해 주세요.';
    }
    notifyListeners();
    return errors.isEmpty ? null : errors.values.first;
  }

  AuctionCreateForm toForm() {
    return AuctionCreateForm(
      categoryId: categoryId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      startingPrice: int.parse(startingPriceController.text),
      bidIncrement: int.parse(bidIncrementController.text),
      startsAt: startsAt!,
      endsAt: endsAt!,
      extensionCount: extensionCount,
      imagePaths: imagePaths,
    );
  }

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.removeListener(_markDirty);
    }
    titleController.dispose();
    descriptionController.dispose();
    startingPriceController.dispose();
    bidIncrementController.dispose();
    super.dispose();
  }
}
