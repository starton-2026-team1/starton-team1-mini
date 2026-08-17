import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      splashColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF6F0F),
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF202124),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
