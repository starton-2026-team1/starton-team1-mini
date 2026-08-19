import 'package:flutter/material.dart';

class AuctionDateTimeField extends StatelessWidget {
  const AuctionDateTimeField({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D3D8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? label : _format(value!),
                style: TextStyle(
                  fontSize: 16,
                  color: value == null
                      ? const Color(0xFF9A9CA2)
                      : const Color(0xFF212124),
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 21,
              color: Color(0xFF868B94),
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}.${value.month}.${value.day}  ${value.hour}:$minute';
  }
}
