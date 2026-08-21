import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_filter_chip_bar.dart';

import '../models/sales_management_filter.dart';

class SalesManagementPage extends StatefulWidget {
  const SalesManagementPage({super.key});

  @override
  State<SalesManagementPage> createState() => _SalesManagementPageState();
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  SalesManagementFilter _selectedFilter = SalesManagementFilter.selling;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMuted,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: const Text(
          '판매관리',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFilterChipBar<SalesManagementFilter>(
            items: SalesManagementFilter.values,
            selectedItem: _selectedFilter,
            labelBuilder: (filter) => '${filter.label} 0',
            onSelected: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
