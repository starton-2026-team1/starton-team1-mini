import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

Future<DateTime?> showAuctionDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AuctionDatePicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _AuctionDatePicker extends StatefulWidget {
  const _AuctionDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_AuctionDatePicker> createState() => _AuctionDatePickerState();
}

class _AuctionDatePickerState extends State<_AuctionDatePicker> {
  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  late DateTime _selectedDate;
  late DateTime _visibleMonth;

  DateTime get _firstMonth =>
      DateTime(widget.firstDate.year, widget.firstDate.month);
  DateTime get _lastMonth =>
      DateTime(widget.lastDate.year, widget.lastDate.month);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildMonthHeader(),
                  const SizedBox(height: 10),
                  _buildWeekdays(),
                  const SizedBox(height: 6),
                  _buildCalendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
                    onPressed: () => Navigator.pop(context, _selectedDate),
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

  Widget _buildMonthHeader() {
    final canGoPrevious = _visibleMonth.isAfter(_firstMonth);
    final canGoNext = _visibleMonth.isBefore(_lastMonth);
    return Row(
      children: [
        IconButton(
          onPressed: canGoPrevious ? () => _changeMonth(-1) : null,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.textPrimary,
          disabledColor: AppColors.iconDisabled,
        ),
        Expanded(
          child: Text(
            '${_visibleMonth.year}년 ${_visibleMonth.month}월',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: canGoNext ? () => _changeMonth(1) : null,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.textPrimary,
          disabledColor: AppColors.iconDisabled,
        ),
      ],
    );
  }

  Widget _buildWeekdays() {
    return Row(
      children: List.generate(
        _weekdays.length,
        (index) => Expanded(
          child: Text(
            _weekdays[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: index == 0 ? AppColors.auction : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekday = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
    ).weekday.remainder(7);
    final itemCount = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        final day = index - firstWeekday + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
        final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
        return _buildDateCell(date);
      },
    );
  }

  Widget _buildDateCell(DateTime date) {
    final isEnabled =
        !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);
    final isSelected = DateUtils.isSameDay(date, _selectedDate);
    final isToday = DateUtils.isSameDay(date, widget.firstDate);

    return InkWell(
      onTap: isEnabled ? () => setState(() => _selectedDate = date) : null,
      customBorder: const CircleBorder(),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            shape: BoxShape.circle,
            border: isToday && !isSelected
                ? Border.all(color: AppColors.primary)
                : null,
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: !isEnabled
                  ? AppColors.iconDisabled
                  : isSelected
                  ? AppColors.white
                  : AppColors.textPrimary,
              fontSize: 15,
              fontWeight: isSelected || isToday
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }
}
