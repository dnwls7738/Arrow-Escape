import 'package:arrow_escape/data/levels.dart';
import 'package:arrow_escape/models/level_data.dart';

bool canShoot(List<ArrowData> currentArrows, ArrowData arrow, int rows, int cols) {
  final dr = arrow.direction.delta.$1;
  final dc = arrow.direction.delta.$2;
  int r = arrow.row + dr;
  int c = arrow.col + dc;

  while (r >= 0 && r < rows && c >= 0 && c < cols) {
    if (currentArrows.any((a) => a.row == r && a.col == c)) {
      return false;
    }
    r += dr;
    c += dc;
  }
  return true;
}

bool solve(List<ArrowData> currentArrows, int rows, int cols) {
  if (currentArrows.isEmpty) return true;

  for (int i = 0; i < currentArrows.length; i++) {
    final arrow = currentArrows[i];
    if (canShoot(currentArrows, arrow, rows, cols)) {
      final nextArrows = List<ArrowData>.from(currentArrows)..removeAt(i);
      if (solve(nextArrows, rows, cols)) {
        return true;
      }
    }
  }
  return false;
}

void main() {
  for (final level in allLevels) {
    final isSolvable = solve(level.arrows, level.rows, level.cols);
    print('Level ${level.id}: ${isSolvable ? "Solvable" : "UNSOLVABLE"}');
  }
}
