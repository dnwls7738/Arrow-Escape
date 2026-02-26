import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/settings_manager.dart';

/// 배경 그리드를 그리는 컴포넌트
class GridComponent extends PositionComponent {
  final int rows;
  final int cols;
  final double cellSize;
  final List<String> emptyCells;

  GridComponent({
    required this.rows,
    required this.cols,
    required this.cellSize,
    this.emptyCells = const [],
  });

  @override
  Future<void> onLoad() async {
    size = Vector2(cols * cellSize, rows * cellSize);
    position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bgPaint = Paint()..color = AppColors.bgDark;
    final linePaint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final showGrid = SettingsManager().showGrid;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final key = '${r}_$c';
        
        // 빈 공간으로 설정된 칸은 그리지 않음
        if (emptyCells.contains(key)) continue;

        final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        
        // 타일 배경
        canvas.drawRect(rect, bgPaint);
        
        // 설정 켜진 경우에만 그리드 테두리
        if (showGrid) {
          canvas.drawRect(rect, linePaint);
        }
      }
    }
  }
}
