import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/main_navigation/pages/main_navigation_page.dart';
import '../shared/theme/app_theme.dart';

const systemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: Colors.white,
  systemNavigationBarContrastEnforced: false,
);

class CarrotMarketApp extends StatelessWidget {
  const CarrotMarketApp({this.home = const MainNavigationPage(), super.key});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '당근마켓',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiStyle,
          child: ColoredBox(
            color: Colors.white,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: home,
    );
  }
}
