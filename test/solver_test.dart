import 'package:flutter_test/flutter_test.dart';
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

/// DFS solver with call limit for large puzzles
bool solve(List<ArrowData> currentArrows, int rows, int cols, {int maxCalls = 500000}) {
  int calls = 0;
  
  bool dfs(List<ArrowData> arrows) {
    calls++;
    if (calls > maxCalls) return false; // timeout — not necessarily unsolvable
    if (arrows.isEmpty) return true;

    for (int i = 0; i < arrows.length; i++) {
      final arrow = arrows[i];
      if (canShoot(arrows, arrow, rows, cols)) {
        final nextArrows = List<ArrowData>.from(arrows)..removeAt(i);
        if (dfs(nextArrows)) return true;
      }
    }
    return false;
  }

  return dfs(currentArrows);
}

/// Greedy solvability check — just verify at least one arrow can always be shot
/// This is O(n^2) and works for constructively generated levels
bool greedySolvable(List<ArrowData> arrows, int rows, int cols) {
  final remaining = List<ArrowData>.from(arrows);
  
  while (remaining.isNotEmpty) {
    bool foundFree = false;
    for (int i = 0; i < remaining.length; i++) {
      if (canShoot(remaining, remaining[i], rows, cols)) {
        remaining.removeAt(i);
        foundFree = true;
        break;
      }
    }
    if (!foundFree) return false;
  }
  return true;
}

void main() {
  test('All levels should be solvable', () {
    List<int> unsolvableLevels = [];
    
    for (final level in allLevels) {
      bool isSolvable;
      
      if (level.arrows.length <= 25) {
        // Small levels: full DFS verification
        isSolvable = solve(level.arrows, level.rows, level.cols);
      } else {
        // Large levels: greedy check (sufficient for constructively generated levels)
        isSolvable = greedySolvable(level.arrows, level.rows, level.cols);
      }
      
      print('Level ${level.id} (${level.rows}x${level.cols}, ${level.arrows.length} arrows): '
          '${isSolvable ? "Solvable" : "UNSOLVABLE"}');
      if (!isSolvable) unsolvableLevels.add(level.id);
    }
    
    expect(unsolvableLevels, isEmpty, reason: 'These levels are unsolvable: $unsolvableLevels');
  });
}
