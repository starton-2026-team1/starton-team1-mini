import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

Future<TimeOfDay?> showAuctionTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AuctionTimePicker(initialTime: initialTime),
  );
}

class _AuctionTimePicker extends StatefulWidget {
  const _AuctionTimePicker({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_AuctionTimePicker> createState() => _AuctionTimePickerState();
}

class _AuctionTimePickerState extends State<_AuctionTimePicker> {
  static const _itemExtent = 56.0;

  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: _itemExtent,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeWheel(
                          controller: _hourController,
                          itemCount: 24,
                          selectedValue: _hour,
                          onSelected: (value) => setState(() => _hour = value),
                        ),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: _TimeWheel(
                          controller: _minuteController,
                          itemCount: 60,
                          selectedValue: _minute,
                          onSelected: (value) =>
                              setState(() => _minute = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      TimeOfDay(hour: _hour, minute: _minute),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.controller,
    required this.itemCount,
    required this.selectedValue,
    required this.onSelected,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedValue;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: _AuctionTimePickerState._itemExtent,
      selectionOverlay: const SizedBox.shrink(),
      useMagnifier: true,
      magnification: 1.12,
      onSelectedItemChanged: onSelected,
      childCount: itemCount,
      itemBuilder: (_, index) => Center(
        child: Text(
          index.toString().padLeft(2, '0'),
          style: TextStyle(
            color: index == selectedValue
                ? AppColors.primary
                : AppColors.textDisabled,
            fontSize: index == selectedValue ? 29 : 23,
            fontWeight: index == selectedValue
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
