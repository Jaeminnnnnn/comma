// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // [공통 텍스트 컬러]
  static const Color warmWhite = Color(0xFFE0E0E0);
  static const Color lightGrey = Color(0xFFAAAAAA);
  static const Color softGrey = Color(0xFF555555);

  // ----------------------------------------------------------------
  // [배경색 팔레트] 7일 주기 파스텔 밤하늘 그라데이션
  // 위쪽(Start)은 통일감을 위해 깊은 밤색으로 고정, 아래쪽(End)만 변화
  // ----------------------------------------------------------------
  static const Color bgStart = Color(0xFF0F1016); // 공통 시작색 (아주 깊은 밤색)

  static const Color bg1End = Color(0xFF221C35); // 1. 퍼플 (신비)
  static const Color bg2End = Color(0xFF1C2235); // 2. 네이비 (차분)
  static const Color bg3End = Color(0xFF1C352D); // 3. 딥 틸 (치유/휴식)
  static const Color bg4End = Color(0xFF3D2C2E); // 4. 더스티 로즈 (온기)
  static const Color bg5End = Color(0xFF2C303D); // 5. 슬레이트 블루 (정돈)
  static const Color bg6End = Color(0xFF251C35); // 6. 인디고 (꿈)
  static const Color bg7End = Color(0xFF352C2C); // 7. 코코아 브라운 (안정)

  // [핵심 함수] 날짜(day)를 받아서 7가지 색상을 순환시키는 자판기
  static BoxDecoration getGradientByDay(int day) {
    // (day - 1) % 7 로 계산하면 0~6 사이의 인덱스가 나옵니다.
    // 즉, day 1, 8, 15, 22 -> index 0 (bg1End)

    int index = (day - 1) % 7;
    Color endColor;

    switch (index) {
      case 0:
        endColor = bg1End;
        break;
      case 1:
        endColor = bg2End;
        break;
      case 2:
        endColor = bg3End;
        break;
      case 3:
        endColor = bg4End;
        break;
      case 4:
        endColor = bg5End;
        break;
      case 5:
        endColor = bg6End;
        break;
      case 6:
        endColor = bg7End;
        break;
      default:
        endColor = bg1End;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgStart, endColor],
      ),
    );
  }
  // ----------------------------------------------------------------

  // 다크 테마 정의
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgStart, // 기본 배경
      primaryColor: warmWhite,

      textTheme: GoogleFonts.nanumMyeongjoTextTheme(
        ThemeData.dark().textTheme.copyWith(
          bodyMedium: const TextStyle(
            color: warmWhite,
            fontSize: 15,
            height: 1.6,
          ),
          titleLarge: const TextStyle(
            color: warmWhite,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          labelSmall: const TextStyle(
            color: lightGrey,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warmWhite,
          side: const BorderSide(color: Colors.white12),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: GoogleFonts.nanumMyeongjo(
            fontSize: 16,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
