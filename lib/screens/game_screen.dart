import 'dart:math' as math;
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../data/score_manager.dart';
import '../data/audio_manager.dart';
import '../data/haptic_manager.dart';
import '../data/ad_manager.dart';
import '../game/arrow_puzzle_game.dart';
import '../models/level_data.dart';
import '../data/levels.dart'; // Ensure it's here
import '../data/level_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  final LevelData levelData;

  const GameScreen({super.key, required this.levelData});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late ArrowPuzzleGame _game;
  late LevelData _currentLevelData;
  int _hearts = 3;
  bool _showClearOverlay = false;
  bool _showGameOverOverlay = false;
  int _stars = 0;
  late AnimationController _clearAnimController;
  late Animation<double> _clearScaleAnim;
  late TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _currentLevelData = widget.levelData;
    _clearAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _clearScaleAnim = CurvedAnimation(
      parent: _clearAnimController,
      curve: Curves.elasticOut,
    );
    _transformController = TransformationController();
    _initGame();
  }

  void _updateInitialScale() {
    // 그리드의 실제 픽셀 크기 (cellSize=20 고정)
    const double cellSize = 20.0;
    final gridW = _currentLevelData.cols * cellSize;
    final gridH = _currentLevelData.rows * cellSize;
    
    // 화면에 맞는 스케일 계산
    final screenW = MediaQuery.of(context).size.width - 64; // padding
    final screenH = MediaQuery.of(context).size.height * 0.6; // game area
    final scaleX = screenW / gridW;
    final scaleY = screenH / gridH;
    final scale = math.min(scaleX, scaleY);
    
    // 중앙 정렬 offset
    final scaledW = gridW * scale;
    final scaledH = gridH * scale;
    final tx = (screenW - scaledW) / 2;
    final ty = (screenH - scaledH) / 2;
    
    _transformController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);
  }

  void _initGame() {
    _game = ArrowPuzzleGame(
      levelData: _currentLevelData,
      onHeartsChanged: () {
        setState(() {
          _hearts = _game.gameState.hearts;
        });
      },
      onLevelComplete: () {
        final stars = _game.gameState.calculateStars();
        // 클리어 처리 추가
        ScoreManager().recordLevelClear(_currentLevelData.id, stars);
        setState(() {
          _showClearOverlay = true;
          _stars = stars;
        });
        _clearAnimController.forward(from: 0);
      },
      onGameOver: () {
        setState(() {
          _showGameOverOverlay = true;
        });
        _clearAnimController.forward(from: 0);
      },
    );
  }

  @override
  void dispose() {
    _clearAnimController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _resetGame() {
    AudioManager().playClick();
    HapticManager().light();
    setState(() {
      _hearts = 3;
      _showClearOverlay = false;
      _showGameOverOverlay = false;
    });
    _game.resetLevel();
  }

  void _undoMove() {
    AudioManager().playUndo();
    HapticManager().light();
    _game.undo();
  }

  void _showHintAdDialog() {
    AudioManager().playClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
         title: Row(
           children: [
             Icon(Icons.lightbulb, color: AppColors.neonPurple),
             const SizedBox(width: 8),
             Text(AppLocalizations.of(context)!.gameHint, style: const TextStyle(color: AppColors.textPrimary)),
           ],
         ),
         content: const Text(
           'Watch a short ad to get a hint?\nThe next available arrow will glow!',
           style: TextStyle(color: AppColors.textSecondary),
         ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showRewardedAd();
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd() {
    AdManager().showRewardedAd(
      onRewarded: () {
        // 광고 시청 완료 → 힌트 표시
        _game.showHint();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('💡 Hint: The glowing arrow can be fired!'),
              backgroundColor: AppColors.neonPurple.withValues(alpha: 0.8),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onNotReady: () {
        // 광고 준비 안 됨 → 무료 힌트 제공
        _game.showHint();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('💡 Free hint! (Ad not ready)'),
              backgroundColor: AppColors.neonGreen.withValues(alpha: 0.8),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
  void _nextLevel() {
    final levels = LevelService().allLevels;
    final currentIndex =
        levels.indexWhere((l) => l.id == _currentLevelData.id);
        
    void proceedToNextLevel() {
      if (currentIndex != -1 && currentIndex < levels.length - 1) {
        setState(() {
          _currentLevelData = levels[currentIndex + 1];
          _showClearOverlay = false;
          _showGameOverOverlay = false;
          _hearts = 3;
          _stars = 0;
        });
        _game.loadNewLevel(_currentLevelData);
      } else {
        Navigator.of(context).pop();
      }
    }

    // 누적 클리어 횟수가 15회 도달 시 전면 광고 표시
    if (ScoreManager().sessionClearCount >= 15) {
      AdManager().showInterstitialAd(onAdClosed: () {
        ScoreManager().resetSessionClearCount(); // 시청 완료 후 카운트 초기화
        proceedToNextLevel();
      });
    } else {
      // 그 외에는 바로 다음 레벨 진행
      proceedToNextLevel();
    }
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
          child: Stack(
            children: [
              Column(
                children: [
                  // 상단 HUD
                  _buildHUD(),
                  // 게임 보드
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 5.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: GameWidget(game: _game),
                        ),
                      ),
                    ),
                  ),
                  // 하단 버튼
                  _buildBottomBar(),
                  const SizedBox(height: 16),
                ],
              ),
              // 레벨 클리어 오버레이
              if (_showClearOverlay) _buildClearOverlay(),
              // 게임 오버 오버레이
              if (_showGameOverOverlay) _buildGameOverOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          // 레벨 번호
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.bgCard,
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.levelNumber(_currentLevelData.id),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neonCyan,
              ),
            ),
          ),
          const Spacer(),
          // 하트 표시
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Icon(
                index < _hearts ? Icons.favorite : Icons.favorite_border,
                color: index < _hearts ? AppColors.neonOrange : AppColors.textMuted,
                size: 24,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.undo_rounded,
            label: AppLocalizations.of(context)!.gameUndo,
            color: AppColors.neonBlue,
            onTap: _undoMove,
          ),
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: AppLocalizations.of(context)!.gameRestart,
            color: AppColors.neonOrange,
            onTap: _resetGame,
          ),
          _buildActionButton(
            icon: Icons.lightbulb_outline_rounded,
            label: AppLocalizations.of(context)!.gameHint,
            color: AppColors.neonPurple,
            onTap: _showHintAdDialog, // 광고 시청 후 힌트 제공
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            color: color.withValues(alpha: 0.08),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearOverlay() {
    return AnimatedBuilder(
      animation: _clearScaleAnim,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Transform.scale(
              scale: _clearScaleAnim.value,
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.bgCard,
                      AppColors.bgDarkSecondary,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.gameClear,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neonCyan,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 별점
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.star_rounded,
                            size: 40,
                            color: i < _stars
                                ? AppColors.neonOrange
                                : AppColors.textMuted.withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Remaining Hearts: $_hearts / 3',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOverlayButton(
                          icon: Icons.refresh_rounded,
                          label: AppLocalizations.of(context)!.gameRestart,
                          color: AppColors.neonOrange,
                          onTap: () {
                            setState(() => _showClearOverlay = false);
                            _resetGame();
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildOverlayButton(
                          icon: Icons.arrow_forward_rounded,
                          label: AppLocalizations.of(context)!.gameNextLevel,
                          color: AppColors.neonCyan,
                          onTap: _nextLevel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return AnimatedBuilder(
      animation: _clearScaleAnim,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Transform.scale(
              scale: _clearScaleAnim.value,
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.bgCard,
                      AppColors.bgDarkSecondary,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.neonOrange.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.heart_broken_rounded,
                      color: AppColors.neonOrange,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.gameOver,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neonOrange,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.gameNoHeartsMsg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildOverlayButton(
                      icon: Icons.refresh_rounded,
                      label: AppLocalizations.of(context)!.gameRestart,
                      color: AppColors.neonOrange,
                      onTap: _resetGame,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
