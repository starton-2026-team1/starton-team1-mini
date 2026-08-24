import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/shared/theme/app_colors.dart';

import '../features/main_navigation/pages/main_navigation_page.dart';
import '../shared/theme/app_theme.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

const systemUiStyle = SystemUiOverlayStyle(
  statusBarColor: AppColors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: AppColors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: AppColors.white,
  systemNavigationBarContrastEnforced: false,
);

class CarrotMarketApp extends StatelessWidget {
  const CarrotMarketApp({this.home = const MainNavigationPage(), super.key});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: '당근마켓',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiStyle,
          child: ColoredBox(
            color: AppColors.white,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: home,
    );
  }
}
