import 'package:flutter/material.dart';

import '../features/main_navigation/pages/main_navigation_page.dart';
import '../shared/theme/app_theme.dart';

class CarrotMarketApp extends StatelessWidget {
  const CarrotMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당근마켓',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigationPage(),
    );
  }
}
