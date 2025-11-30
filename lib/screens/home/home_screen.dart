import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:comma/core/theme/app_theme.dart';
import 'package:comma/screens/report/phase_report_screen.dart';
import 'package:comma/screens/history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final int day = 1; // [Tip] 테스트용

  final String question = "오늘,\n누군가에게 건넨\n첫 마디가\n상냥했나요?";
  bool _isAnswered = false;
  String? _myAnswer;

  late AnimationController _statsFadeController;
  late Animation<double> _statsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _statsFadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsFadeAnimation = CurvedAnimation(
      parent: _statsFadeController,
      curve: Curves.easeOutQuart,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((day - 1) % 7 == 0 && day > 1) {
        _showPhaseReportOverlay();
      }
    });
  }

  void _showPhaseReportOverlay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => PhaseReportScreen(phaseNumber: (day ~/ 7)),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _handleAnswer(String answer) {
    setState(() {
      _isAnswered = true;
      _myAnswer = answer;
    });
    _statsFadeController.forward();
  }

  @override
  void dispose() {
    _statsFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppTheme.getGradientByDay(day),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.04), // 상단 여백 약간 줄임
                // [수정된 헤더] 콤마 -> Day -> Phase 순서로 수직 배치
                Center(
                  child: Column(
                    children: [
                      // 1. 지난 기록 버튼 (콤마 아이콘)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ), // 터치 영역 넉넉하게
                          child: Text(
                            ",",
                            style: GoogleFonts.nanumMyeongjo(
                              fontSize: 32, // 크기를 키워서 장식처럼 보이게
                              color: AppTheme.softGrey.withOpacity(0.8),
                              height: 0.5, // 텍스트 높이를 줄여서 Day와 가깝게 붙임
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10), // 콤마와 Day 사이 간격
                      // 2. Day 텍스트
                      Text(
                        "Day $day",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          letterSpacing: 2.5,
                          color: AppTheme.lightGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 3. Phase 타이틀
                      Text(
                        _getPhaseTitle(),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.lightGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.1),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(question, style: textTheme.titleLarge),
                ),

                const Spacer(),

                SizedBox(
                  height: size.height * 0.35,
                  child: _isAnswered
                      ? _buildStatsArea(textTheme)
                      : _buildButtonArea(textTheme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPhaseTitle() {
    if (day <= 7) return "Phase 1. 무뎌진 감각 깨우기";
    if (day <= 14) return "Phase 2. 잊고 지낸 온기 찾기";
    if (day <= 21) return "Phase 3. 나를 돌보는 마음";
    return "Phase 4. 일상의 결 정돈하기";
  }

  Widget _buildButtonArea(TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleAnswer('no'),
                child: const Text("NO"),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleAnswer('yes'),
                child: const Text("YES"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "오늘 하루는 어땠나요?\n당신의 솔직한 마음을 남겨주세요.\n(기록은 익명으로 안전하게 보관돼요.)",
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightGrey,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsArea(TextTheme textTheme) {
    return FadeTransition(
      opacity: _statsFadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatRow("YES", 0.42, _myAnswer == 'yes'),
          const SizedBox(height: 24),
          _buildStatRow("NO", 0.58, _myAnswer == 'no'),
          const SizedBox(height: 45),
          Text(
            _myAnswer == 'yes'
                ? "오늘도 나를 아껴주어서 고마워요."
                : "괜찮아요, 내일은 조금 더 다정해져 볼까요?",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 12),
          Text(
            "다음 쉼표까지  04 : 12 : 33",
            style: GoogleFonts.lato(
              color: AppTheme.lightGrey,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double percentage, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.nanumMyeongjo(
                color: isSelected ? AppTheme.warmWhite : AppTheme.lightGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: GoogleFonts.nanumMyeongjo(
                color: isSelected ? AppTheme.warmWhite : AppTheme.lightGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(height: 3, width: double.infinity, color: Colors.white10),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 3,
                color: isSelected ? AppTheme.warmWhite : AppTheme.softGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
