import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auction_create_form.dart';

enum AuctionCreateField {
  title,
  description,
  place,
  startingPrice,
  bidIncrement,
  buyNowPrice,
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
  final placeController = TextEditingController();
  final startingPriceController = TextEditingController();
  final bidIncrementController = TextEditingController();
  final buyNowPriceController = TextEditingController();

  final now = DateTime.now();

  DateTime? startsAt;
  DateTime? endsAt;
  int extensionCount = 0;
  bool acceptPriceOffers = false;
  bool isDirty = false;
  final Map<AuctionCreateField, String> errors = {};

  List<TextEditingController> get _textControllers => [
    titleController,
    descriptionController,
    placeController,
    startingPriceController,
    bidIncrementController,
    buyNowPriceController,
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

  void setAcceptPriceOffers(bool value) {
    acceptPriceOffers = value;
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
    if (placeController.text.trim().isEmpty) {
      errors[AuctionCreateField.place] = '거래 희망 장소를 입력해 주세요.';
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
    final buyNowText = buyNowPriceController.text;
    final buyNowPrice = int.tryParse(buyNowText);
    if (buyNowText.isNotEmpty &&
        (buyNowPrice == null ||
            startingPrice == null ||
            buyNowPrice <= startingPrice)) {
      errors[AuctionCreateField.buyNowPrice] = '바로 입찰 가격은 시작 가격보다 높아야 해요.';
    }
    notifyListeners();
    return errors.isEmpty ? null : errors.values.first;
  }

  AuctionCreateForm toForm() {
    return AuctionCreateForm(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      place: placeController.text.trim(),
      startingPrice: int.parse(startingPriceController.text),
      bidIncrement: int.parse(bidIncrementController.text),
      startsAt: startsAt!,
      endsAt: endsAt!,
      buyNowPrice: int.tryParse(buyNowPriceController.text),
      extensionCount: extensionCount,
      acceptPriceOffers: acceptPriceOffers,
    );
  }

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.removeListener(_markDirty);
    }
    titleController.dispose();
    descriptionController.dispose();
    placeController.dispose();
    startingPriceController.dispose();
    bidIncrementController.dispose();
    buyNowPriceController.dispose();
    super.dispose();
  }
}
