import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/auction_create_form.dart';

class AuctionCreateController extends ChangeNotifier {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final placeController = TextEditingController();
  final startingPriceController = TextEditingController();
  final bidIncrementController = TextEditingController();
  final buyNowPriceController = TextEditingController();

  DateTime? startsAt;
  DateTime? endsAt;
  int extensionCount = 0;
  bool acceptPriceOffers = false;

  static final priceFormatter = FilteringTextInputFormatter.digitsOnly;

  void setStartsAt(DateTime value) {
    startsAt = value;
    if (endsAt != null && !endsAt!.isAfter(value)) {
      endsAt = value.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  void setEndsAt(DateTime value) {
    endsAt = value;
    notifyListeners();
  }

  void setExtensionCount(int value) {
    extensionCount = value;
    notifyListeners();
  }

  void setAcceptPriceOffers(bool value) {
    acceptPriceOffers = value;
    notifyListeners();
  }

  String? validate() {
    if (titleController.text.trim().isEmpty) return '제목을 입력해 주세요.';
    if (descriptionController.text.trim().isEmpty) return '자세한 설명을 입력해 주세요.';
    if (placeController.text.trim().isEmpty) return '거래 희망 장소를 입력해 주세요.';
    final startingPrice = int.tryParse(startingPriceController.text);
    if (startingPrice == null || startingPrice <= 0) return '시작 가격을 입력해 주세요.';
    final bidIncrement = int.tryParse(bidIncrementController.text);
    if (bidIncrement == null || bidIncrement <= 0) return '최소 입찰 단위를 입력해 주세요.';
    if (startsAt == null) return '경매 시작 시간을 선택해 주세요.';
    if (endsAt == null) return '경매 종료 시간을 선택해 주세요.';
    if (!endsAt!.isAfter(startsAt!)) return '종료 시간은 시작 시간보다 늦어야 해요.';
    final buyNowText = buyNowPriceController.text;
    final buyNowPrice = int.tryParse(buyNowText);
    if (buyNowText.isNotEmpty &&
        (buyNowPrice == null || buyNowPrice <= startingPrice)) {
      return '바로 입찰 가격은 시작 가격보다 높아야 해요.';
    }
    return null;
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
    titleController.dispose();
    descriptionController.dispose();
    placeController.dispose();
    startingPriceController.dispose();
    bidIncrementController.dispose();
    buyNowPriceController.dispose();
    super.dispose();
  }
}
