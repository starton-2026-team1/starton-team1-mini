import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      hoverColor: AppColors.transparent,
      focusColor: AppColors.transparent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.textStrong,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.transparent,
      ),
    );
  }
}
