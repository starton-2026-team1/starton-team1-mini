import 'package:flutter/material.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import 'profile_temperature_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.userName,
    required this.mannerTemperature,
    required this.onTap,
    super.key,
  });

  final String userName;
  final double mannerTemperature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 29,
                backgroundColor: AppColors.iconMuted,
                child: Icon(Icons.person, size: 42, color: AppColors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textStrong,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ProfileTemperatureBadge(temperature: mannerTemperature),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
