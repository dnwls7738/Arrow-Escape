import '../core/constants.dart';

/// 2D 그리드 위의 한 지점(행, 열)
class Coordinate {
  final int row;
  final int col;

  const Coordinate({required this.row, required this.col});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinate && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);
  
  @override
  String toString() => '($row, $col)';
}

/// 연속된 블록들을 하나로 이은 경로 (뱀 / 선 형태)
class PathData {
  final int id;
  final int colorIndex; // 선 색상을 구별하기 위한 인덱스
  
  /// 경로를 구성하는 1x1 블록들의 좌표 리스트
  /// [0]이 꼬리(Tail), [segments.length - 1]이 머리(Head) 즉 화살촉 방향입니다.
  final List<Coordinate> segments;

  const PathData({
    required this.id,
    required this.colorIndex,
    required this.segments,
  });

  PathData copyWith({int? id, int? colorIndex, List<Coordinate>? segments}) {
    return PathData(
      id: id ?? this.id,
      colorIndex: colorIndex ?? this.colorIndex,
      segments: segments ?? List.from(this.segments),
    );
  }

  /// 화살표 머리가 가리키는 방향 벡터(dr, dc) 반환
  (int, int) get headDirection {
    if (segments.length < 2) return (0, 0); // 점이 1개면 방향 없음
    final last = segments.last;
    final prev = segments[segments.length - 2];
    
    int dr = 0, dc = 0;
    if (last.row > prev.row) dr = 1;
    else if (last.row < prev.row) dr = -1;
    
    if (last.col > prev.col) dc = 1;
    else if (last.col < prev.col) dc = -1;
    
    return (dr, dc);
  }
  
  ArrowDirection get arrowDirection {
    final (dr, dc) = headDirection;
    if (dr == -1) return ArrowDirection.up;
    if (dr == 1) return ArrowDirection.down;
    if (dc == -1) return ArrowDirection.left;
    if (dc == 1) return ArrowDirection.right;
    return ArrowDirection.up; // Fallback
  }
}

/// 레벨 데이터
class LevelData {
  final int id;
  final int chapter;
  final int rows;
  final int cols;
  final List<PathData> paths;
  final int par; // 목표 이동 횟수
  final List<String> emptyCells; // 비활성화된 공간 (포맷: "row_col")

  const LevelData({
    required this.id,
    required this.chapter,
    required this.rows,
    required this.cols,
    required this.paths,
    required this.par,
    this.emptyCells = const [],
  });
}
