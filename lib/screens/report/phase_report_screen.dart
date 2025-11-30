// lib/screens/report/phase_report_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:comma/core/theme/app_theme.dart';

class PhaseReportScreen extends StatefulWidget {
  final int phaseNumber;

  const PhaseReportScreen({super.key, required this.phaseNumber});

  @override
  State<PhaseReportScreen> createState() => _PhaseReportScreenState();
}

class _PhaseReportScreenState extends State<PhaseReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  int _currentCardIndex = 0;

  // 더미 데이터 (나중엔 DB에서 받아오게 수정 가능)
  final List<Map<String, dynamic>> _dummyGlobalStats = [
    {
      "day": 1,
      "question": "오늘,\n갈증이 나기 전에\n물 한 잔을 챙겨\n마셨나요?",
      "yes": 72,
      "myChoice": "yes",
    },
    {
      "day": 2,
      "question": "오늘,\n스마트폰 화면이 아닌\n'진짜 하늘'을\n올려다보았나요?",
      "yes": 45,
      "myChoice": "no",
    },
    {
      "day": 3,
      "question": "오늘 식사를 할 때,\n영상 없이 온전히\n맛을 음미했나요?",
      "yes": 61,
      "myChoice": "yes",
    },
    {
      "day": 4,
      "question": "오늘,\n굳어있는 몸을 위해\n한 번이라도\n기지개를 켰나요?",
      "yes": 88,
      "myChoice": "yes",
    },
    {
      "day": 5,
      "question": "오늘,\n이어폰을 빼고\n주변의 백색 소음을\n들어보았나요?",
      "yes": 34,
      "myChoice": "no",
    },
    {
      "day": 6,
      "question": "오늘,\n거울 속의 내 눈을\n3초 이상\n바라봐 준 적이\n있나요?",
      "yes": 21,
      "myChoice": "yes",
    },
    {
      "day": 7,
      "question": "오늘,\n의식적으로\n깊은 심호흡을\n한 번이라도 했나요?",
      "yes": 55,
      "myChoice": "yes",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  void _close() async {
    await _fadeController.reverse();
    if (mounted) Navigator.pop(context); // 닫기
  }

  void _dismissCard() {
    if (_currentCardIndex < _dummyGlobalStats.length) {
      setState(() {
        _currentCardIndex++;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 투명 배경 (뒤가 비치도록)
      body: FadeTransition(
        opacity: _fadeController,
        child: Container(
          // 배경: 뒤에 홈화면이 살짝 비치는 반투명 블랙
          color: Colors.black.withOpacity(0.85),
          child: SafeArea(
            child: Column(
              children: [
                // 상단 닫기 버튼 (히스토리에서 볼 때 유용)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.lightGrey),
                    onPressed: _close,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. 맨 뒤: 최종 정산 카드
                      _buildMyFinalReportCard(),

                      // 2. 앞: 글로벌 통계 카드들
                      for (
                        int i = _dummyGlobalStats.length - 1;
                        i >= _currentCardIndex;
                        i--
                      )
                        _buildGlobalStatCard(
                          key: ValueKey("card_$i"),
                          index: i,
                          data: _dummyGlobalStats[i],
                          isTop: i == _currentCardIndex,
                          isDismissed: i < _currentCardIndex,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalStatCard({
    required Key key,
    required int index,
    required Map<String, dynamic> data,
    required bool isTop,
    required bool isDismissed,
  }) {
    int relativeIndex = index - _currentCardIndex;
    String myChoice = data['myChoice'].toString().toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      transform: isDismissed
          ? (Matrix4.identity()
              ..translate(500.0, -50.0)
              ..rotateZ(0.2))
          : (Matrix4.identity()
              ..translate(0.0, relativeIndex * 15.0, 0.0)
              ..scale(1.0 - (relativeIndex * 0.05))),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isDismissed ? 0.0 : 1.0,
        child: GestureDetector(
          onTap: isTop ? _dismissCard : null,
          child: Container(
            width: 320,
            height: 520,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF353535), Color(0xFF151515)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "Phase ${widget.phaseNumber} Report",
                      style: GoogleFonts.lato(
                        color: AppTheme.softGrey,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Day ${data['day']}",
                      style: GoogleFonts.lato(
                        color: AppTheme.warmWhite,
                        fontSize: 18,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 40),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${data['question']}",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.nanumMyeongjo(
                          fontSize: 20,
                          color: AppTheme.warmWhite,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: data['yes'] / 100,
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.warmWhite,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "${data['yes']}%",
                                style: GoogleFonts.nanumMyeongjo(
                                  fontSize: 26,
                                  color: AppTheme.warmWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Global YES",
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  color: AppTheme.lightGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.lightGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "My Record : ",
                              style: GoogleFonts.nanumMyeongjo(
                                fontSize: 13,
                                color: AppTheme.lightGrey,
                              ),
                            ),
                            Text(
                              myChoice,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: AppTheme.warmWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Text(
                  "카드를 터치하여 넘기세요",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.softGrey.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyFinalReportCard() {
    int yesCount = _dummyGlobalStats
        .where((d) => d['myChoice'] == 'yes')
        .length;
    return Container(
      width: 320,
      height: 520,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF353535), Color(0xFF151515)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.warmWhite.withOpacity(0.8),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                "Phase ${widget.phaseNumber} Journey",
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: AppTheme.lightGrey,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "일주일 동안,\n당신은 당신을",
                textAlign: TextAlign.center,
                style: GoogleFonts.nanumMyeongjo(
                  fontSize: 18,
                  color: AppTheme.warmWhite,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$yesCount번",
                style: GoogleFonts.nanumMyeongjo(
                  fontSize: 48,
                  color: AppTheme.warmWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "사랑해주었네요.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nanumMyeongjo(
                  fontSize: 18,
                  color: AppTheme.warmWhite,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _close,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.warmWhite.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.white.withOpacity(0.02),
              ),
              child: Text(
                "닫기",
                style: GoogleFonts.nanumMyeongjo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
