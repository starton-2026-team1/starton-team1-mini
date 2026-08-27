import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

class AuctionDateTimeField extends StatelessWidget {
  const AuctionDateTimeField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
    super.key,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText == null ? AppColors.border : AppColors.error,
                width: errorText == null ? 1 : 1.5,
              ),
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
                          ? AppColors.textPlaceholder
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 21,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, color: AppColors.error, size: 17),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _format(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}.${value.month}.${value.day}  ${value.hour}:$minute';
  }
}
