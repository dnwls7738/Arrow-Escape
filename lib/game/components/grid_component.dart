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

    final dotPaint = Paint()
      ..color = AppColors.gridLine.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final key = '${r}_$c';
        
        // 빈 공간으로 설정된 칸은 그리지 않음
        if (emptyCells.contains(key)) continue;

        final center = Offset(c * cellSize + cellSize / 2, r * cellSize + cellSize / 2);
        
        // 점(Dot)
        canvas.drawCircle(center, 2.0, dotPaint);
      }
    }
  }
}
