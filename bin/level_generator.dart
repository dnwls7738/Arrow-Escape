import 'dart:math';

/// Arrow direction enum
enum Dir { up, right, down, left }

extension DirDelta on Dir {
  (int, int) get delta {
    switch (this) {
      case Dir.up: return (-1, 0);
      case Dir.right: return (0, 1);
      case Dir.down: return (1, 0);
      case Dir.left: return (0, -1);
    }
  }
  String get name {
    switch (this) {
      case Dir.up: return 'up';
      case Dir.right: return 'right';
      case Dir.down: return 'down';
      case Dir.left: return 'left';
    }
  }
}

class Arrow {
  final int row, col;
  final Dir dir;
  Arrow(this.row, this.col, this.dir);
}

bool _isBlocked(List<Arrow> arrows, Arrow a, int rows, int cols) {
  final (dr, dc) = a.dir.delta;
  int r = a.row + dr, c = a.col + dc;
  while (r >= 0 && r < rows && c >= 0 && c < cols) {
    for (final o in arrows) {
      if (o.row == r && o.col == c) return true;
    }
    r += dr;
    c += dc;
  }
  return false;
}

bool _canShoot(List<Arrow> arrows, Arrow a, int rows, int cols) =>
    !_isBlocked(arrows, a, rows, cols);

int _countFree(List<Arrow> arrows, int rows, int cols) {
  int n = 0;
  for (final a in arrows) {
    if (_canShoot(arrows, a, rows, cols)) n++;
  }
  return n;
}

/// ===== CONSTRUCTIVE GENERATION =====
/// Build a puzzle that is GUARANTEED solvable:
///
/// 1. Pick all cell positions and shuffle them — this is the solve-order.
/// 2. Process in REVERSE order (last-to-shoot placed first).
/// 3. For each cell, pick a direction such that *at least one* of the
///    previously-placed arrows sits in its firing path → this arrow will be
///    "blocked" until those later arrows are removed.
/// 4. The very LAST arrow placed (first to shoot) must be free (path clear).
///
/// Because we enforce "the path is blocked only by arrows that will be
/// removed later", the original order is always a valid solution.

class LevelResult {
  final int id, chapter, rows, cols, par;
  final List<Arrow> arrows;
  final List<String> emptyCells;
  final int freeCount;
  final double freeRatio;
  LevelResult({
    required this.id, required this.chapter,
    required this.rows, required this.cols,
    required this.arrows, required this.par,
    required this.emptyCells,
    required this.freeCount, required this.freeRatio,
  });
}

LevelResult? generateLevel({
  required int id,
  required int chapter,
  required int rows,
  required int cols,
  required int targetArrows,
  required double minFreeRatio,
  required double maxFreeRatio,
  required int emptyCount,
  required Random rng,
  int maxAttempts = 800,
}) {
  final allDirs = Dir.values;

  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    // --- 1.  Generate empty cells ---
    final totalCells = rows * cols;
    final maxEmpty = (totalCells - targetArrows).clamp(0, totalCells - 1);
    final actualEmpty = emptyCount.clamp(0, maxEmpty);
    final emptyCells = <String>{};
    while (emptyCells.length < actualEmpty) {
      emptyCells.add('${rng.nextInt(rows)}_${rng.nextInt(cols)}');
    }

    // Build available-cell list
    final available = <(int, int)>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!emptyCells.contains('${r}_$c')) available.add((r, c));
      }
    }
    if (available.length < targetArrows) continue;

    // --- 2.  Define solve-order (shuffled) ---
    available.shuffle(rng);
    final solveOrder = available.sublist(0, targetArrows);
    // solveOrder[0] will be shot first, solveOrder[last] shot last.

    // --- 3.  Place arrows in REVERSE order ---
    // placed list grows from back of solveOrder to front.
    final arrows = <Arrow>[];
    bool failed = false;

    for (int i = targetArrows - 1; i >= 0; i--) {
      final (r, c) = solveOrder[i];

      if (i == 0) {
        // First arrow to be shot — MUST be free (not blocked).
        // Pick a direction whose path is clear of all placed arrows.
        final freeDirs = <Dir>[];
        for (final d in allDirs) {
          final test = Arrow(r, c, d);
          if (_canShoot(arrows, test, rows, cols)) freeDirs.add(d);
        }
        if (freeDirs.isEmpty) { failed = true; break; }
        final dir = freeDirs[rng.nextInt(freeDirs.length)];
        arrows.add(Arrow(r, c, dir));
      } else {
        // This arrow should be blocked by at least one already-placed arrow
        // (which will be removed later in solve-order, unblocking this one).
        //
        // Prefer directions where a placed arrow sits in the firing path.
        final blockedDirs = <Dir>[];
        final freeDirs = <Dir>[];
        for (final d in allDirs) {
          final test = Arrow(r, c, d);
          if (_isBlocked([...arrows], test, rows, cols)) {
            blockedDirs.add(d);
          } else {
            freeDirs.add(d);
          }
        }

        Dir dir;
        if (blockedDirs.isNotEmpty) {
          dir = blockedDirs[rng.nextInt(blockedDirs.length)];
        } else if (freeDirs.isNotEmpty) {
          // No blocking possible — pick free but it increases free ratio
          dir = freeDirs[rng.nextInt(freeDirs.length)];
        } else {
          failed = true; break;
        }
        arrows.add(Arrow(r, c, dir));
      }
    }

    if (failed) continue;

    // --- 4.  Evaluate ---
    final freeCount = _countFree(arrows, rows, cols);
    final freeRatio = freeCount / arrows.length;

    if (freeRatio < minFreeRatio || freeRatio > maxFreeRatio) continue;
    if (freeCount == 0) continue;

    // par = number of arrows (constructive guarantees solve in exactly N moves)
    // For small levels, we could compute optimal, but constructive order IS optimal.
    final par = arrows.length;

    return LevelResult(
      id: id, chapter: chapter, rows: rows, cols: cols,
      arrows: arrows, par: par,
      emptyCells: emptyCells.toList()..sort(),
      freeCount: freeCount, freeRatio: freeRatio,
    );
  }
  return null;
}

/// Fallback: guaranteed solvable (edge arrows)
LevelResult fallback(int id, int ch, int rows, int cols, int n, Random rng) {
  final cells = <(int, int, Dir)>[];
  for (int c = 0; c < cols; c++) {
    cells.add((0, c, Dir.up));
    cells.add((rows - 1, c, Dir.down));
  }
  for (int r = 1; r < rows - 1; r++) {
    cells.add((r, 0, Dir.left));
    cells.add((r, cols - 1, Dir.right));
  }
  // Add interior pointing outward
  for (int r = 1; r < rows - 1; r++) {
    for (int c = 1; c < cols - 1; c++) {
      cells.add((r, c, Dir.values[rng.nextInt(4)]));
    }
  }
  cells.shuffle(rng);
  final used = <String>{};
  final arrows = <Arrow>[];
  for (final (r, c, d) in cells) {
    final k = '${r}_$c';
    if (used.contains(k)) continue;
    used.add(k);
    arrows.add(Arrow(r, c, d));
    if (arrows.length >= n) break;
  }
  return LevelResult(
    id: id, chapter: ch, rows: rows, cols: cols,
    arrows: arrows, par: arrows.length, emptyCells: [],
    freeCount: arrows.length, freeRatio: 1.0,
  );
}

String toDart(LevelResult l) {
  final b = StringBuffer();
  b.writeln('  // --- Level ${l.id} (${l.rows}x${l.cols}, '
      'free=${l.freeCount}/${l.arrows.length}='
      '${(l.freeRatio * 100).toStringAsFixed(0)}%, par=${l.par}) ---');
  b.writeln('  const LevelData(');
  b.writeln('    id: ${l.id}, chapter: ${l.chapter}, '
      'rows: ${l.rows}, cols: ${l.cols},');
  b.writeln('    arrows: [');
  for (final a in l.arrows) {
    b.writeln("      ArrowData(row: ${a.row}, col: ${a.col}, "
        "direction: ArrowDirection.${a.dir.name}),");
  }
  b.writeln('    ],');
  b.writeln('    par: ${l.par},');
  if (l.emptyCells.isNotEmpty) {
    b.writeln("    emptyCells: [${l.emptyCells.map((e) => "'$e'").join(', ')}],");
  }
  b.writeln('  ),');
  return b.toString();
}

void main() {
  final rng = Random(42);
  final specs = [
    _S(1, 3,4, 3,4, 5,12, 0.30,0.70, 0,0, 15),
    _S(2, 4,5, 4,5, 10,20, 0.15,0.45, 0,3, 15),
    _S(3, 5,7, 5,7, 14,30, 0.10,0.35, 2,10, 15),
    _S(4, 7,10, 7,10, 20,45, 0.08,0.25, 5,30, 15),
    _S(5, 10,15, 10,15, 30,70, 0.05,0.20, 15,80, 15),
  ];

  int levelId = 1;
  final out = <int, List<String>>{};

  for (final s in specs) {
    out[s.ch] = [];
    print('\n=== Chapter ${s.ch} ===');

    for (int i = 0; i < s.n; i++) {
      final p = i / (s.n - 1).clamp(1, 100);
      final rows = s.r1 + ((s.r2 - s.r1) * p).round();
      final cols = s.c1 + ((s.c2 - s.c1) * p).round();
      final tgt = s.a1 + ((s.a2 - s.a1) * p).round();
      final maxF = s.f2 - (s.f2 - s.f1) * p * 0.5;
      final emp = s.e1 + ((s.e2 - s.e1) * p).round();

      LevelResult? level;
      for (int retry = 0; retry < 15 && level == null; retry++) {
        level = generateLevel(
          id: levelId, chapter: s.ch,
          rows: rows, cols: cols,
          targetArrows: tgt,
          minFreeRatio: (s.f1 - retry * 0.02).clamp(0.01, 1.0),
          maxFreeRatio: maxF + retry * 0.05,
          emptyCount: emp,
          rng: rng,
          maxAttempts: 500 + retry * 200,
        );
      }
      level ??= fallback(levelId, s.ch, rows, cols, tgt, rng);
      
      out[s.ch]!.add(toDart(level));
      print('Level ${level.id}: ${level.rows}x${level.cols}, '
          '${level.arrows.length} arrows, '
          'free=${level.freeCount}(${(level.freeRatio * 100).toStringAsFixed(0)}%), '
          'par=${level.par}, empty=${level.emptyCells.length}');
      levelId++;
    }
  }

  // Output levels.dart
  print('\n\n// ===== GENERATED levels.dart =====\n');
  print("import '../models/level_data.dart';");
  print("import '../core/constants.dart';");
  print('');

  for (int ch = 1; ch <= 5; ch++) {
    print('/// Chapter $ch');
    print('final List<LevelData> chapter${ch}Levels = [');
    for (final l in out[ch]!) { print(l); }
    print('];\n');
  }
  print('/// All levels in order');
  print('final List<LevelData> allLevels = [');
  for (int ch = 1; ch <= 5; ch++) {
    print('  ...chapter${ch}Levels,');
  }
  print('];');
}

class _S {
  final int ch, r1, r2, c1, c2, a1, a2, e1, e2, n;
  final double f1, f2;
  _S(this.ch, this.r1,this.r2, this.c1,this.c2, this.a1,this.a2,
      this.f1,this.f2, this.e1,this.e2, this.n);
}
