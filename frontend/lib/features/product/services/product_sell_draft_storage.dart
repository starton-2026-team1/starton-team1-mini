import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_sell_draft.dart';

class ProductSellDraftStorage {
  static const _storageKey = 'product_sell_draft';

  Future<void> save(ProductSellDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(draft.toJson()));
  }

  Future<ProductSellDraft?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    if (value == null) {
      return null;
    }

    try {
      return ProductSellDraft.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } on FormatException {
      await preferences.remove(_storageKey);
      return null;
    } on TypeError {
      await preferences.remove(_storageKey);
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
