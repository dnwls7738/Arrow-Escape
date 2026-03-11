import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'package:arrow_escape/l10n/app_localizations.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bgController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgDark,
                  AppColors.bgDarkSecondary,
                  HSLColor.fromAHSL(
                    1.0,
                    (_bgController.value * 360) % 360,
                    0.3,
                    0.08,
                  ).toColor(),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // 게임 로고
                _buildLogo(),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                    letterSpacing: 8,
                  ),
                ),
                const Spacer(flex: 2),
                // 메뉴 버튼
                _buildMenuButton(
                  label: AppLocalizations.of(context)!.menuPlay,
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.neonCyan,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const LevelSelectScreen(),
                        transitionsBuilder: (_, anim, __, child) {
                          return FadeTransition(opacity: anim, child: child);
                        },
                        transitionDuration:
                            const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  label: AppLocalizations.of(context)!.menuSettings,
                  icon: Icons.settings_rounded,
                  color: AppColors.textSecondary,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SettingsScreen(),
                        transitionsBuilder: (_, anim, __, child) {
                          return FadeTransition(opacity: anim, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  small: true,
                ),
                const Spacer(),
                // 버전 표시
                Text(
                  'v1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool small = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: small ? 48 : AppSizes.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: small ? 20 : 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: small ? 14 : 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
