import 'dart:async'; // 타이머용
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 저장소
import 'package:comma/core/theme/app_theme.dart';
import 'package:comma/screens/report/phase_report_screen.dart';
import 'package:comma/screens/history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // [수정] 이제 day는 고정값이 아니라 계산된 값이 들어갑니다.
  int day = 1;
  String _timeRemaining = "00:00:00"; // 남은 시간 표시용

  String question = "";
  bool _isLoading = true;
  bool _isAnswered = false;
  String? _myAnswer;

  // 실시간 통계
  int _currentYesCount = 0;
  int _currentNoCount = 0;

  late AnimationController _statsFadeController;
  late Animation<double> _statsFadeAnimation;
  Timer? _timer; // 1초마다 가는 타이머

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

    // 1. Day 계산 및 데이터 로딩 시작
    _initializeDayAndData();

    // 2. 1초마다 남은 시간 갱신 (다음 밤 9시까지)
    _startTimer();
  }

  // [초기화] 앱 켤 때 Day 계산 (밤 9시 기준)
  Future<void> _initializeDayAndData() async {
    final prefs = await SharedPreferences.getInstance();

    String? dateString = prefs.getString('first_run_date');
    if (dateString == null) {
      dateString = DateTime.now().toIso8601String();
      await prefs.setString('first_run_date', dateString);
    }

    DateTime installTime = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    // 1. 기준 시간 복구: 설치일의 '밤 9시'
    DateTime firstNinePM = DateTime(
      installTime.year,
      installTime.month,
      installTime.day,
      21,
      0,
      0,
    );

    // 2. 로직 복구: 설치 시간이 이미 9시를 넘었으면 -> 첫 갱신은 내일 9시
    if (installTime.hour >= 21) {
      firstNinePM = firstNinePM.add(const Duration(days: 1));
    }

    if (now.isBefore(firstNinePM)) {
      day = 1;
    } else {
      int daysPassed = now.difference(firstNinePM).inDays;
      day = 2 + daysPassed;
    }

    setState(() {});
    _loadDailyData();

    if ((day - 1) % 7 == 0 && day > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPhaseReportOverlay();
      });
    }
  }

  // [타이머] 1초마다 체크 (밤 9시 기준)
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      DateTime now = DateTime.now();

      // 1. 보여주는 시간 목표: 오늘 밤 9시
      DateTime targetTime = DateTime(now.year, now.month, now.day, 21, 0, 0);

      if (now.isAfter(targetTime)) {
        targetTime = targetTime.add(const Duration(days: 1));
      }
      Duration diff = targetTime.difference(now);

      String h = diff.inHours.toString().padLeft(2, '0');
      String m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      String s = (diff.inSeconds % 60).toString().padLeft(2, '0');

      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        String? dateString = prefs.getString('first_run_date');

        if (dateString != null) {
          DateTime installTime = DateTime.parse(dateString);

          // 2. 실제 계산 기준: 설치일의 밤 9시
          DateTime firstNinePM = DateTime(
            installTime.year,
            installTime.month,
            installTime.day,
            21,
            0,
            0,
          );

          // 로직 복구: 21시 넘어서 설치했으면 내일로 미룸
          if (installTime.hour >= 21) {
            firstNinePM = firstNinePM.add(const Duration(days: 1));
          }

          int calculatedDay = 1;
          if (now.isAfter(firstNinePM)) {
            int daysPassed = now.difference(firstNinePM).inDays;
            calculatedDay = 2 + daysPassed;
          }

          if (calculatedDay > day) {
            print("🌙 밤 9시가 되었습니다! 새로운 질문으로 넘어갑니다.");
            // Day 업데이트 및 데이터 새로고침
            setState(() {
              day = calculatedDay;
            });
            _loadDailyData();
          }
        }

        setState(() {
          _timeRemaining = "$h : $m : $s";
        });
      }
    });
  }

  Future<void> _loadDailyData() async {
    try {
      String docId = "day_$day";

      final prefs = await SharedPreferences.getInstance();
      String? savedAnswer = prefs.getString(docId);

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('questions')
          .doc(docId)
          .get();

      if (doc.exists) {
        setState(() {
          question = doc['question'].toString().replaceAll('\\n', '\n');
          _currentYesCount = doc['yes'] ?? 0;
          _currentNoCount = doc['no'] ?? 0;

          // [핵심 수정] 저장된 답변이 있는지 확인
          if (savedAnswer != null) {
            // 1. 답변이 있으면 -> 결과 화면 보여주기
            _isAnswered = true;
            _myAnswer = savedAnswer;
            _statsFadeController.value = 1.0;
          } else {
            // 2. 답변이 없으면(새로운 날) -> [초기화] 투표 화면 보여주기!
            _isAnswered = false;
            _myAnswer = null;
            _statsFadeController.value = 0.0; // 애니메이션도 리셋
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          question = "준비된 질문이\n모두 끝났습니다.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("에러: $e");
      setState(() {
        question = "인터넷 연결을\n확인해주세요.";
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAnswer(String answer) async {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _myAnswer = answer;
      if (answer == 'yes') _currentYesCount++;
      if (answer == 'no') _currentNoCount++;
    });
    _statsFadeController.forward();

    try {
      String docId = "day_$day";
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(docId)
          .update({answer: FieldValue.increment(1)});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(docId, answer);
    } catch (e) {
      print("저장 실패: $e");
    }
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

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제 필수
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
                SizedBox(height: size.height * 0.04),

                // [헤더]
                Center(
                  child: Column(
                    children: [
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
                          ),
                          child: Text(
                            ",",
                            style: GoogleFonts.nanumMyeongjo(
                              fontSize: 32,
                              color: AppTheme.softGrey.withOpacity(0.8),
                              height: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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

                // [질문]
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.lightGrey,
                          ),
                        )
                      : Text(question, style: textTheme.titleLarge),
                ),

                const Spacer(),

                // [하단]
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
    if (day <= 28) return "Phase 4. 일상의 결 정돈하기";
    if (day <= 35) return "Phase 5. 새로운 시선";
    if (day <= 42) return "Phase 6. 소음 줄이기";
    return "Phase 7. 단단한 중심";
  }

  Widget _buildButtonArea(TextTheme textTheme) {
    if (_isLoading) return const SizedBox();

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
    int total = _currentYesCount + _currentNoCount;
    double yesPercent = total == 0 ? 0 : _currentYesCount / total;
    double noPercent = total == 0 ? 0 : _currentNoCount / total;

    return FadeTransition(
      opacity: _statsFadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatRow("YES", yesPercent, _myAnswer == 'yes'),
          const SizedBox(height: 24),
          _buildStatRow("NO", noPercent, _myAnswer == 'no'),

          const SizedBox(height: 45),

          Text(
            _myAnswer == 'yes'
                ? "오늘도 나를 아껴주어서 고마워요."
                : "괜찮아요, 내일은 조금 더 다정해져 볼까요?",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 12),
          // [NEW] 실제 작동하는 타이머 표시
          Text(
            "다음 질문까지  $_timeRemaining",
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
