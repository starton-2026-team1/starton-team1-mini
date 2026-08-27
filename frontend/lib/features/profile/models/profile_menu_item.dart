import 'package:flutter/material.dart';

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.label,
    required this.icon,
    required this.routeKey,
  });

  final String label;
  final IconData icon;
  final String routeKey;
}
