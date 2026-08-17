import 'package:flutter/material.dart';

import 'views/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 앱 실행 시 웰컴 페이지 표시
    return MaterialApp(home: WelcomePage());
  }
}
