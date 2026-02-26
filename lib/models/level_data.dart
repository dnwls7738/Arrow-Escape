import '../core/constants.dart';

/// 하나의 화살표 데이터
class ArrowData {
  final int row;
  final int col;
  final ArrowDirection direction;

  const ArrowData({
    required this.row,
    required this.col,
    required this.direction,
  });

  ArrowData copyWith({int? row, int? col, ArrowDirection? direction}) {
    return ArrowData(
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowData &&
          row == other.row &&
          col == other.col &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(row, col, direction);
}

/// 레벨 데이터
class LevelData {
  final int id;
  final int chapter;
  final int rows;
  final int cols;
  final List<ArrowData> arrows;
  final int par; // 목표 이동 횟수
  final List<String> emptyCells; // 비활성화된 공간 (포맷: "row_col", 모양 구성용)

  const LevelData({
    required this.id,
    required this.chapter,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.par,
    this.emptyCells = const [],
  });
}
