import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auction_draft.dart';

class AuctionDraftStorage {
  static const _storageKey = 'auction_create_draft';

  Future<void> save(AuctionDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(draft.toJson()));
  }

  Future<AuctionDraft?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_storageKey);
    if (value == null) return null;

    try {
      return AuctionDraft.fromJson(jsonDecode(value) as Map<String, dynamic>);
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
