// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart'; // [필수] 저장소
import 'package:comma/firebase_options.dart';
import 'package:comma/core/theme/app_theme.dart';
import 'package:comma/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // [NEW] 설치 날짜 저장 로직
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('first_run_date') == null) {
    // 저장된 날짜가 없으면(첫 실행이면) 지금 시간을 저장
    await prefs.setString('first_run_date', DateTime.now().toIso8601String());
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CommaApp());
}

class CommaApp extends StatelessWidget {
  const CommaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
