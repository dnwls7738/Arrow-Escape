import '../models/level_data.dart';
import '../core/constants.dart';

/// 선(뱀) 풀기 퍼즐 게임 상태를 관리하는 클래스
class GameState {
  final LevelData levelData;
  List<PathData> _currentPaths;
  final List<List<PathData>> _undoStack = [];
  final List<int> _heartsUndoStack = []; // 이전 하트 개수 저장용
  int _hearts = 3;
  int _moveCount = 0; // 뒤로가기 등 내부 통계용으로 유지 (UI에서는 미사용)
  bool _isCompleted = false;

  GameState({required this.levelData})
      : _currentPaths = List.from(levelData.paths);

  // Getters
  List<PathData> get currentPaths => List.unmodifiable(_currentPaths);
  int get hearts => _hearts;
  bool get isGameOver => _hearts <= 0;
  int get moveCount => _moveCount;
  bool get isCompleted => _isCompleted;
  int get par => levelData.par;
  int get rows => levelData.rows;
  int get cols => levelData.cols;

  /// 해당 위치에 있는 선(뱀) 반환
  PathData? getPathAt(int row, int col) {
    for (final path in _currentPaths) {
      for (final segment in path.segments) {
        if (segment.row == row && segment.col == col) {
          return path;
        }
      }
    }
    return null;
  }

  /// 선(뱀)이 충돌 없이 완전히 빠져나갈 수 있는지 시뮬레이션
  bool canEscape(PathData targetPath) {
    if (targetPath.segments.isEmpty) return true;
    
    // 시뮬레이션을 위해 몸통 좌표 복사
    List<Coordinate> simSegments = List.from(targetPath.segments);
    final (dr, dc) = targetPath.headDirection;
    if (dr == 0 && dc == 0) return false; // 방향이 없는 경우 불가
    
    int maxSteps = rows * cols + targetPath.segments.length + 5;
    
    for (int step = 0; step < maxSteps; step++) {
      Coordinate head = simSegments.last;
      Coordinate newHead = Coordinate(row: head.row + dr, col: head.col + dc);
      
      bool isOut = newHead.row < 0 || newHead.row >= rows || newHead.col < 0 || newHead.col >= cols;
      
      if (!isOut) {
        // 보드 내부인 경우 충돌 검사
        for (final path in _currentPaths) {
          if (path.id == targetPath.id) {
            // 자가 충돌: 새로운 머리가 시뮬레이션 상의 내 몸통에 닿는지 검사
            // (꼬리 simSegments[0]는 이번 턴에 이동해서 벗어나므로 검사에서 제외)
            for (int i = 1; i < simSegments.length; i++) {
              if (simSegments[i] == newHead) return false;
            }
          } else {
            // 다른 뱀과 충돌: 다른 뱀은 가만히 있다고 가정
            // 정확한 "겹침" 검사: 다른 뱀의 어떤 관절(segment)에라도 닿으면 충돌
            for (final segment in path.segments) {
              if (segment == newHead) return false;
            }
          }
        }
      }
      
      // 전진
      simSegments.add(newHead);
      simSegments.removeAt(0); // 꼬리 자르기
      
      // 보드에 남은 몸통이 하나도 없는지 확인
      bool allOut = true;
      for (final s in simSegments) {
        if (s.row >= 0 && s.row < rows && s.col >= 0 && s.col < cols) {
          allOut = false;
          break;
        }
      }
      if (allOut) return true; // 무사히 빠져나감
    }
    
    return false; // 무한루프 방지
  }

  /// 탭한 선을 빠져나가도록(제거) 시도
  bool escape(PathData path) {
    if (!canEscape(path)) return false;

    // Undo를 위해 복사본 저장
    _undoStack.add(List.from(_currentPaths));
    _heartsUndoStack.add(_hearts);
    
    _currentPaths.removeWhere((p) => p.id == path.id);
    _moveCount++;

    if (_currentPaths.isEmpty) {
      _isCompleted = true;
    }

    return true;
  }

  /// 잘못된 이동 기록 (선 탭했는데 못 나갈 때)
  void recordWrongMove() {
    _undoStack.add(List.from(_currentPaths));
    _heartsUndoStack.add(_hearts);
    _moveCount++;
    
    if (_hearts > 0) {
      _hearts--;
    }
  }

  /// 마지막 동작 취소
  bool undo() {
    if (_undoStack.isEmpty) return false;

    _currentPaths = _undoStack.removeLast();
    _hearts = _heartsUndoStack.removeLast();
    _moveCount--;
    _isCompleted = false;
    return true;
  }

  /// 레벨 리셋
  void reset() {
    _currentPaths = List.from(levelData.paths);
    _undoStack.clear();
    _heartsUndoStack.clear();
    _hearts = 3;
    _moveCount = 0;
    _isCompleted = false;
  }

  /// 별점 계산 (남은 하트 기반)
  int calculateStars() {
    if (!_isCompleted) return 0;
    return _hearts; // 남아있는 하트 개수가 곧 획득 별점
  }

  /// 힌트
  PathData? getHint() {
    for (final path in _currentPaths) {
      if (canEscape(path)) return path;
    }
    return null;
  }
}
