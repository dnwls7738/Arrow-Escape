import '../models/level_data.dart';
import '../core/constants.dart';

/// 게임 상태를 관리하는 클래스
class GameState {
  final LevelData levelData;
  List<ArrowData> _currentArrows;
  final List<List<ArrowData>> _undoStack = [];
  int _moveCount = 0;
  bool _isCompleted = false;

  GameState({required this.levelData})
      : _currentArrows = List.from(levelData.arrows);

  // Getters
  List<ArrowData> get currentArrows => List.unmodifiable(_currentArrows);
  int get moveCount => _moveCount;
  bool get isCompleted => _isCompleted;
  int get par => levelData.par;
  int get rows => levelData.rows;
  int get cols => levelData.cols;

  /// 해당 위치에 화살표가 있는지 확인
  ArrowData? getArrowAt(int row, int col) {
    for (final arrow in _currentArrows) {
      if (arrow.row == row && arrow.col == col) return arrow;
    }
    return null;
  }

  /// 화살표가 발사 가능한지 확인 (경로에 다른 화살표가 없어야 함)
  bool canShoot(ArrowData arrow) {
    final (dr, dc) = arrow.direction.delta;
    int r = arrow.row + dr;
    int c = arrow.col + dc;

    // 화살표 방향으로 보드 밖까지 경로 확인
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (getArrowAt(r, c) != null) return false;
      r += dr;
      c += dc;
    }
    return true;
  }

  /// 화살표 발사 (제거)
  bool shoot(ArrowData arrow) {
    if (!canShoot(arrow)) return false;

    // Undo를 위해 현재 상태 저장
    _undoStack.add(List.from(_currentArrows));
    _currentArrows.remove(arrow);
    _moveCount++;

    if (_currentArrows.isEmpty) {
      _isCompleted = true;
    }

    return true;
  }

  /// 잘못된 이동 기록 (차단된 화살표 탭시 호출)
  void recordWrongMove() {
    _undoStack.add(List.from(_currentArrows));
    _moveCount++;
  }

  /// 마지막 동작 취소
  bool undo() {
    if (_undoStack.isEmpty) return false;

    _currentArrows = _undoStack.removeLast();
    _moveCount--;
    _isCompleted = false;
    return true;
  }

  /// 레벨 초기 상태로 리셋
  void reset() {
    _currentArrows = List.from(levelData.arrows);
    _undoStack.clear();
    _moveCount = 0;
    _isCompleted = false;
  }

  /// 별점 계산
  /// 별 3개: 이동 횟수 <= 화살표 수 (최소 이동)
  /// 별 2개: 화살표 수 < 이동 횟수 <= 화살표 수 * 2
  /// 별 1개: 이동 횟수 > 화살표 수 * 2
  int calculateStars() {
    if (!_isCompleted) return 0;
    final arrowCount = levelData.arrows.length;
    if (_moveCount <= arrowCount) return 3;
    if (_moveCount <= arrowCount * 2) return 2;
    return 1;
  }

  /// 힌트: 현재 발사 가능한 화살표 하나를 반환
  ArrowData? getHint() {
    for (final arrow in _currentArrows) {
      if (canShoot(arrow)) return arrow;
    }
    return null;
  }
}
