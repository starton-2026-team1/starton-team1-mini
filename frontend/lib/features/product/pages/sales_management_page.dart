import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_filter_chip_bar.dart';

import '../data/mock_sales_management_items.dart';
import '../models/sales_management_filter.dart';
import '../models/sales_management_item.dart';
import '../widgets/sales_management_item_card.dart';

class SalesManagementPage extends StatefulWidget {
  const SalesManagementPage({super.key});

  @override
  State<SalesManagementPage> createState() => _SalesManagementPageState();
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  SalesManagementFilter _selectedFilter = SalesManagementFilter.auction;

  List<SalesManagementItem> get _filteredItems => mockSalesManagementItems
      .where((item) => item.filter == _selectedFilter)
      .toList();

  int _countFor(SalesManagementFilter filter) {
    return mockSalesManagementItems
        .where((item) => item.filter == filter)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMuted,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: const Text(
          '판매/경매관리',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFilterChipBar<SalesManagementFilter>(
            items: SalesManagementFilter.values,
            selectedItem: _selectedFilter,
            labelBuilder: (filter) => '${filter.label} ${_countFor(filter)}',
            onSelected: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _filteredItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return SalesManagementItemCard(item: _filteredItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
