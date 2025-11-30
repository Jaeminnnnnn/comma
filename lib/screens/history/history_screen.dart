import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:comma/core/theme/app_theme.dart';
import 'package:comma/screens/report/phase_report_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중엔 현재 진행 상황에 따라 달라짐)
    final int currentPhase = 2; // 현재 Phase 2 진행 중이라고 가정

    return Scaffold(
      // [수정] nightStart -> bgStart 로 변경
      backgroundColor: AppTheme.bgStart,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "지난 여정",
          style: GoogleFonts.nanumMyeongjo(color: AppTheme.warmWhite),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.warmWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 4, // 총 4개의 페이즈
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          int phaseNum = index + 1;
          bool isUnlocked = phaseNum < currentPhase; // 지나간 페이즈만 열람 가능

          return _buildPhaseItem(context, phaseNum, isUnlocked);
        },
      ),
    );
  }

  Widget _buildPhaseItem(BuildContext context, int phaseNum, bool isUnlocked) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              // [클릭] 리포트 화면을 '투명한 라우트'로 띄워서 뒤가 비치게 함
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false, // 투명 배경 허용
                  pageBuilder: (_, __, ___) =>
                      PhaseReportScreen(phaseNumber: phaseNum),
                  transitionsBuilder: (_, anim, __, child) {
                    return FadeTransition(opacity: anim, child: child);
                  },
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.02), // 잠긴 건 더 어둡게
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Icon(
              isUnlocked ? Icons.auto_awesome : Icons.lock_outline,
              color: isUnlocked ? AppTheme.warmWhite : AppTheme.softGrey,
              size: 20,
            ),
            const SizedBox(width: 16),

            // 텍스트
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phase $phaseNum",
                  style: GoogleFonts.lato(
                    color: isUnlocked ? AppTheme.lightGrey : AppTheme.softGrey,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPhaseTitle(phaseNum),
                  style: GoogleFonts.nanumMyeongjo(
                    color: isUnlocked ? AppTheme.warmWhite : AppTheme.softGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const Spacer(),

            if (isUnlocked)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.softGrey,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  String _getPhaseTitle(int phase) {
    switch (phase) {
      case 1:
        return "무뎌진 감각 깨우기";
      case 2:
        return "잊고 지낸 온기 찾기";
      case 3:
        return "나를 돌보는 마음";
      case 4:
        return "일상의 결 정돈하기";
      default:
        return "";
    }
  }
}
