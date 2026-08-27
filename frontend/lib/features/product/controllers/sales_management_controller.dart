import 'package:flutter/foundation.dart';

import '../data/sales_management_api.dart';
import '../models/sales_management_filter.dart';
import '../models/sales_management_item.dart';

class SalesManagementController extends ChangeNotifier {
  SalesManagementController(this._gateway);

  final SalesManagementGateway _gateway;

  List<SalesManagementItem> _items = const [];
  SalesManagementFilter _selectedFilter = SalesManagementFilter.auction;
  bool _isLoading = false;
  String? _errorMessage;

  List<SalesManagementItem> get items => _items;
  SalesManagementFilter get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SalesManagementItem> get filteredItems => _items
      .where((item) => item.filter == _selectedFilter)
      .toList(growable: false);

  int countFor(SalesManagementFilter filter) =>
      _items.where((item) => item.filter == filter).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _gateway.listMyProducts(),
        _gateway.listMyBids(),
      ]);
      _items = [...results[0], ...results[1]];
    } catch (_) {
      _errorMessage = '판매 및 입찰 내역을 불러오지 못했어요.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFilter(SalesManagementFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }
}
