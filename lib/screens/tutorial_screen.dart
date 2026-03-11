import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import 'package:arrow_escape/l10n/app_localizations.dart';

/// 첫 실행 시 게임 규칙을 안내하는 온보딩 튜토리얼 화면
class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({super.key, required this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_TutorialPage> _getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _TutorialPage(
        icon: Icons.touch_app_rounded,
        title: l10n.tutorialPage1Title,
        description: l10n.tutorialPage1Desc,
        color: AppColors.neonCyan,
      ),
      _TutorialPage(
        icon: Icons.block_rounded,
        title: l10n.tutorialPage2Title,
        description: l10n.tutorialPage2Desc,
        color: AppColors.neonOrange,
      ),
      _TutorialPage(
        icon: Icons.stars_rounded,
        title: l10n.tutorialPage3Title,
        description: l10n.tutorialPage3Desc,
        color: AppColors.neonGreen,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgDark, AppColors.bgDarkSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip 버튼
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeTutorial,
                  child: Text(
                    AppLocalizations.of(context)!.tutorialSkip,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // 페이지 뷰
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _getPages(context).length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _getPages(context)[index];
                    return _buildPage(page);
                  },
                ),
              ),

              // 페이지 인디케이터
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_getPages(context).length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? _getPages(context)[_currentPage].color
                            : AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),
              ),

              // Next / Start 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _nextPage(_getPages(context).length),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPages(context)[_currentPage].color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _getPages(context).length - 1 
                          ? AppLocalizations.of(context)!.tutorialStart 
                          : AppLocalizations.of(context)!.tutorialNext,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘 (네온 글로우)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),

          // 제목
          Text(
            page.title,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: page.color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          // 설명
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
