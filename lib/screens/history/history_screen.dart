import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:comma/core/theme/app_theme.dart';
import 'package:comma/screens/report/phase_report_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중엔 현재 진행 상황에 따라 달라짐)
    final int currentPhase = 2;

    return Scaffold(
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
        itemCount: 8, // 7개 페이즈 + 1개(안내 문구)
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          // 마지막 아이템은 텍스트만 표시
          if (index == 7) {
            return _buildComingSoonText();
          }

          int phaseNum = index + 1;
          bool isUnlocked = phaseNum < currentPhase;

          return _buildPhaseItem(context, phaseNum, isUnlocked);
        },
      ),
    );
  }

  // [수정됨] 카드/아이콘 없이 텍스트만 깔끔하게 표시
  Widget _buildComingSoonText() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20), // 위아래 여백을 줘서 숨통을 틔움
      child: Center(
        child: Text(
          "새로운 페이즈가 추가될 예정이에요",
          style: GoogleFonts.lato(
            color: AppTheme.softGrey.withOpacity(0.4), // 아주 은은하게
            fontSize: 12,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseItem(BuildContext context, int phaseNum, bool isUnlocked) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
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
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.auto_awesome : Icons.lock_outline,
              color: isUnlocked ? AppTheme.warmWhite : AppTheme.softGrey,
              size: 20,
            ),
            const SizedBox(width: 16),
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
      case 5:
        return "새로운 시선";
      case 6:
        return "소음 줄이기";
      case 7:
        return "단단한 중심";
      default:
        return "";
    }
  }
}
