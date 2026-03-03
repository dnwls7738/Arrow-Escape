import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/level_data.dart';
import 'game_state.dart';
import 'components/arrow_component.dart';
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
  final VoidCallback? onMoveCountChanged;
  final VoidCallback? onLevelComplete;

  final Map<String, ArrowComponent> _arrowComponents = {};
  int _activeAnimations = 0;

  ArrowPuzzleGame({
    required this.levelData,
    this.onMoveCountChanged,
    this.onLevelComplete,
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
    final availableWidth = size.x - AppSizes.gridPadding * 2;
    final availableHeight = size.y - AppSizes.gridPadding * 2;
    cellSize = (availableWidth / levelData.cols)
        .clamp(0, availableHeight / levelData.rows)
        .toDouble();
  }

  void _setupBoard() {
    _arrowComponents.clear();

    // 보드 영역 계산 (중앙 배치)
    final boardWidth = levelData.cols * cellSize;
    final boardHeight = levelData.rows * cellSize;
    final offsetX = (size.x - boardWidth) / 2;
    final offsetY = (size.y - boardHeight) / 2;

    // 보드 컨테이너
    final boardContainer = PositionComponent(
      position: Vector2(offsetX, offsetY),
      size: Vector2(boardWidth, boardHeight),
    );

    // 그리드 배경 (빈 칸은 그리지 않음)
    boardContainer.add(GridComponent(
      rows: levelData.rows,
      cols: levelData.cols,
      cellSize: cellSize,
      emptyCells: levelData.emptyCells,
    ));

    // 화살표 배치
    for (final arrowData in gameState.currentArrows) {
      final key = '${arrowData.row}_${arrowData.col}';
      
      // 혹시라도 비어있는 공간으로 지정된 곳이면 화살표를 배치하지 않음 (안전 장치)
      if (levelData.emptyCells.contains(key)) continue;

      final component = ArrowComponent(
        arrowData: arrowData,
        cellSize: cellSize,
        onTap: () => _onArrowTapped(arrowData),
      );
      _arrowComponents[key] = component;
      boardContainer.add(component);
    }

    add(boardContainer);
  }

  void _onArrowTapped(ArrowData arrowData) {
    final key = '${arrowData.row}_${arrowData.col}';
    final component = _arrowComponents[key];
    if (component == null || component.isRemoving) return;

    if (gameState.canShoot(arrowData)) {
      // 즉시 논리적 상태 업데이트 (다중 터치 허용)
      gameState.shoot(arrowData);
      _arrowComponents.remove(key);
      
      AudioManager().playShoot();
      HapticManager().medium();
      onMoveCountChanged?.call();

      // 발사 트레일 이펙트
      final (dr, dc) = arrowData.direction.delta;
      final boardWidth = levelData.cols * cellSize;
      final boardHeight = levelData.rows * cellSize;
      final offsetX = (size.x - boardWidth) / 2;
      final offsetY = (size.y - boardHeight) / 2;
      final arrowCenterX = offsetX + arrowData.col * cellSize + cellSize / 2;
      final arrowCenterY = offsetY + arrowData.row * cellSize + cellSize / 2;
      add(ShootTrail(
        startX: arrowCenterX,
        startY: arrowCenterY,
        dirX: dc.toDouble(),
        dirY: dr.toDouble(),
        color: AppColors.colorForDirection(arrowData.direction),
        cellSize: cellSize,
      ));

      _activeAnimations++;
      component.playShootAnimation(() {
        _activeAnimations--;

        if (gameState.isCompleted && _activeAnimations == 0) {
          AudioManager().playClear();
          HapticManager().success();
          // 축하 파티클 폭발!
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
      onMoveCountChanged?.call();
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
    onMoveCountChanged?.call();
  }

  /// 레벨 리셋
  void resetLevel() {
    gameState.reset();
    _activeAnimations = 0;
    removeAll(children);
    _setupBoard();
    onMoveCountChanged?.call();
  }

  /// Undo
  void undo() {
    if (gameState.undo()) {
      removeAll(children);
      _setupBoard();
      onMoveCountChanged?.call();
    }
  }

  /// 힌트: 발사 가능한 화살표를 깜빡이게 표시
  void showHint() {
    final hintArrow = gameState.getHint();
    if (hintArrow == null) return;

    final key = '${hintArrow.row}_${hintArrow.col}';
    final component = _arrowComponents[key];
    if (component != null) {
      component.playHintAnimation();
    }
  }
}
