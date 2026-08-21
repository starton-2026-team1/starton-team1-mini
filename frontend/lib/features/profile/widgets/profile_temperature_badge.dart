import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

class ProfileTemperatureBadge extends StatelessWidget {
  const ProfileTemperatureBadge({required this.temperature, super.key});

  final double temperature;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.temperatureContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          '${temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(
            color: AppColors.temperature,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
