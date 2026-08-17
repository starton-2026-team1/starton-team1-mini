import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shared/theme/app_theme.dart';
import 'views/welcome_page.dart';

const systemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarDividerColor: Colors.white,
  systemNavigationBarContrastEnforced: false,
);

void main() {
  SystemChrome.setSystemUIOverlayStyle(systemUiStyle);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 앱 실행 시 웰컴 페이지 표시
    return MaterialApp(
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
      home: const WelcomePage(),
    );
  }
}
