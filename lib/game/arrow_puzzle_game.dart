import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/level_data.dart';
import 'game_state.dart';
import 'components/path_component.dart';
import 'components/grid_component.dart';
import '../data/settings_manager.dart';
import '../data/audio_manager.dart';
import '../data/haptic_manager.dart';
import 'components/particle_effects.dart';

/// Arrow Puzzle 메인 게임 클래스
class ArrowPuzzleGame extends FlameGame {
  LevelData levelData;
  late GameState gameState;
  late double cellSize;
  
  // 콜백
  final VoidCallback? onHeartsChanged;
  final VoidCallback? onLevelComplete;
  final VoidCallback? onGameOver;

  final Map<int, PathComponent> _pathComponents = {};
  int _activeAnimations = 0;

  ArrowPuzzleGame({
    required this.levelData,
    this.onHeartsChanged,
    this.onLevelComplete,
    this.onGameOver,
  });

  @override
  Color backgroundColor() => AppColors.bgDark;

  @override
  Future<void> onLoad() async {
    gameState = GameState(levelData: levelData);
    _calculateCellSize();
    _setupBoard();
    
    // 설정 변경 감지 리스너 등록
    SettingsManager().addListener(_onSettingsChanged);
  }

  @override
  void onRemove() {
    SettingsManager().removeListener(_onSettingsChanged);
    super.onRemove();
  }

  void _onSettingsChanged() {
    // 그리드 설정 등이 변경되면 보드를 다시 그립니다.
    removeAll(children);
    _setupBoard();
  }

  void _calculateCellSize() {
    // 내부 고정 셀 크기 (물리적 비율 유지용)
    cellSize = 20.0;
  }

  void _setupBoard() {
    _pathComponents.clear();

    // 내부 그리드 크기 (20px 기준)
    final boardWidth = levelData.cols * cellSize;
    final boardHeight = levelData.rows * cellSize;
    
    // 화면에 맞는 스케일 계산
    final availableWidth = size.x - 32;
    final availableHeight = size.y - 32;
    final scaleX = availableWidth / boardWidth;
    final scaleY = availableHeight / boardHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    // 스케일 적용 후 중앙 배치
    final scaledBoardWidth = boardWidth * scale;
    final scaledBoardHeight = boardHeight * scale;
    final offsetX = (size.x - scaledBoardWidth) / 2;
    final offsetY = (size.y - scaledBoardHeight) / 2;

    // 보드 컨테이너 (스케일 적용)
    final boardContainer = PositionComponent(
      position: Vector2(offsetX, offsetY),
      size: Vector2(boardWidth, boardHeight),
      scale: Vector2.all(scale),
    );

    // 그리드 배경
    boardContainer.add(GridComponent(
      rows: levelData.rows,
      cols: levelData.cols,
      cellSize: cellSize,
      emptyCells: levelData.emptyCells,
    ));

    // 선(뱀) 배치
    for (final pathData in gameState.currentPaths) {
      final component = PathComponent(
        pathData: pathData,
        cellSize: cellSize,
        onTap: () => _onPathTapped(pathData),
      );

      _pathComponents[pathData.id] = component;
      boardContainer.add(component);
    }

    add(boardContainer);
  }

  void _onPathTapped(PathData pathData) {
    final component = _pathComponents[pathData.id];
    if (component == null || component.isRemoving) return;

    if (gameState.escape(pathData)) {
      AudioManager().playShoot();
      HapticManager().medium();
      onHeartsChanged?.call();

      _pathComponents.remove(pathData.id);

      _activeAnimations++;
      component.playShootAnimation(() {
        _activeAnimations--;

        if (gameState.isCompleted && _activeAnimations == 0) {
          AudioManager().playClear();
          HapticManager().success();
          add(CelebrationParticle(screenSize: size));
          onLevelComplete?.call();
        }
      });
    } else {
      if (component.isShaking) return;

      component.playBlockedAnimation();
      gameState.recordWrongMove();
      AudioManager().playBlocked();
      HapticManager().heavy();
      onHeartsChanged?.call();

      if (gameState.isGameOver) {
        onGameOver?.call();
      }
    }
  }

  /// 새 레벨 로드 (엔진 재구동 없이 상태만 변경)
  void loadNewLevel(LevelData newLevelData) {
    levelData = newLevelData;
    gameState = GameState(levelData: levelData);
    _calculateCellSize();
    _activeAnimations = 0;
    removeAll(children);
    _setupBoard();
    onHeartsChanged?.call();
  }

  /// 레벨 리셋
  void resetLevel() {
    gameState.reset();
    _activeAnimations = 0;
    removeAll(children);
    _setupBoard();
    onHeartsChanged?.call();
  }

  /// Undo
  void undo() {
    if (gameState.undo()) {
      removeAll(children);
      _setupBoard();
      onHeartsChanged?.call();
    }
  }

  /// 힌트: 빠져나갈 수 있는 선을 깜빡이게 표시
  void showHint() {
    final hintPath = gameState.getHint();
    if (hintPath == null) return;

    final component = _pathComponents[hintPath.id];
    if (component != null) {
      component.playHintAnimation();
    }
  }
}
