// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comma/core/theme/app_theme.dart'; // 방금 만든 테마 불러오기
import 'package:comma/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상단 상태바(배터리, 시간) 투명하게 만들기 (몰입감 UP)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // 아이콘은 흰색
    ),
  );

  runApp(const CommaApp());
}

class CommaApp extends StatelessWidget {
  const CommaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comma', // 앱 이름
      debugShowCheckedModeBanner: false, // 디버그 띠 제거
      // 디자인 시스템 적용
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // 다크모드 강제
      // 임시 홈 화면 (다음 단계에서 멋지게 바꿀 예정)
      home: const HomeScreen(),
    );
  }
}
