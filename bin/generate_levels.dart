import 'dart:io';
import 'dart:math';

/// ==========================================================
/// Greedy Peeling Level Generator (v6 — FINAL)
///
/// 1. 모든 셀에 랜덤 방향 배정
/// 2. "쏠 수 있는" 화살표를 하나씩 벗겨냄
///    벗겨낼 수 없으면 방향을 보정하여 강제로 벗김
/// 3. 100% 밀도 + 100% 풀이 보장
/// ==========================================================

enum Dir { up, down, left, right }

extension DirExt on Dir {
  (int, int) get delta {
    switch (this) {
      case Dir.up: return (-1, 0);
      case Dir.down: return (1, 0);
      case Dir.left: return (0, -1);
      case Dir.right: return (0, 1);
    }
  }
  String get dartName => 'ArrowDirection.${toString().split('.').last}';
}

class Cell {
  final int r, c;
  Dir dir;
  Cell(this.r, this.c, this.dir);
}

// ---- 최적화된 유틸리티 (Set.difference 제거) ----

/// 경로 위에 occupied에 포함된 셀이 있는지 (자기 자신 좌표는 무시)
bool canShoot(int r, int c, Dir dir, int rows, int cols, Set<int> occupied) {
  final (dr, dc) = dir.delta;
  int cr = r + dr, cc = c + dc;
  while (cr >= 0 && cr < rows && cc >= 0 && cc < cols) {
    int key = cr * 100 + cc;
    if (occupied.contains(key)) return false;
    cr += dr;
    cc += dc;
  }
  return true;
}

/// 그리디 필링으로 보드 생성
(List<Cell>, int)? buildBoard(int rows, int cols, Random rand) {
  // 1. 모든 셀에 랜덤 방향 배정
  List<Cell> board = [];
  Set<int> occupied = {};
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      board.add(Cell(r, c, Dir.values[rand.nextInt(4)]));
      occupied.add(r * 100 + c);
    }
  }
  
  // 2. 그리디 필링
  List<Cell> remaining = [...board];
  int corrections = 0;
  int maxCorrections = rows * cols * 8;
  
  while (remaining.isNotEmpty) {
    int shootIdx = -1;
    for (int i = 0; i < remaining.length; i++) {
      final a = remaining[i];
      // 자기 자신 임시 제거 후 확인
      int key = a.r * 100 + a.c;
      occupied.remove(key);
      bool ok = canShoot(a.r, a.c, a.dir, rows, cols, occupied);
      occupied.add(key); // 복원
      if (ok) { shootIdx = i; break; }
    }
    
    if (shootIdx >= 0) {
      final a = remaining.removeAt(shootIdx);
      occupied.remove(a.r * 100 + a.c);
    } else {
      if (corrections >= maxCorrections) return null;
      
      // 랜덤 셀의 방향 변경
      int idx = rand.nextInt(remaining.length);
      final a = remaining[idx];
      int key = a.r * 100 + a.c;
      occupied.remove(key);
      
      List<Dir> freeDirs = [];
      for (final d in Dir.values) {
        if (canShoot(a.r, a.c, d, rows, cols, occupied)) freeDirs.add(d);
      }
      
      occupied.add(key); // 복원
      
      if (freeDirs.isNotEmpty) {
        a.dir = freeDirs[rand.nextInt(freeDirs.length)];
      }
      corrections++;
    }
  }
  
  // 초기 자유도 계산
  Set<int> allOcc = {for (final c in board) c.r * 100 + c.c};
  int freeCount = 0;
  for (final a in board) {
    int key = a.r * 100 + a.c;
    allOcc.remove(key);
    if (canShoot(a.r, a.c, a.dir, rows, cols, allOcc)) freeCount++;
    allOcc.add(key);
  }
  
  board.shuffle(rand);
  return (board, freeCount);
}

void main() {
  final rand = Random();
  final buf = StringBuffer();
  buf.writeln("import '../models/level_data.dart';");
  buf.writeln("import '../core/constants.dart';\n");

  int gid = 1;
  List<String> chapterNames = [];

  for (int ch = 1; ch <= 5; ch++) {
    int maxR, maxC, maxFree;
    switch (ch) {
      case 1: maxR = 4; maxC = 4; maxFree = 6; break;
      case 2: maxR = 5; maxC = 5; maxFree = 5; break;
      case 3: maxR = 6; maxC = 6; maxFree = 5; break;
      case 4: maxR = 7; maxC = 7; maxFree = 6; break;    // 100% 밀도 자체가 어려움
      case 5: maxR = 8; maxC = 8; maxFree = 7; break;    // 100% 밀도 자체가 어려움
      default: maxR = 4; maxC = 4; maxFree = 6;
    }

    String vn = 'chapter${ch}Levels';
    chapterNames.add(vn);
    buf.writeln("/// Chapter $ch");
    buf.writeln("final List<LevelData> $vn = [");

    for (int lv = 1; lv <= 15; lv++) {
      double prog = (lv - 1) / 14.0;
      int curR = maxR, curC = maxC;

      if (prog < 0.2) { curR = max(3, maxR - 1); curC = max(3, maxC - 1); }

      int levelMaxFree = max(2, (maxFree - (prog * 2)).toInt());

      // 최적 보드 탐색 (각 시도 매우 빠름)
      List<Cell>? bestBoard;
      int bestFree = 999;

      // 보드 크기에 따라 시도 횟수 조정
      int maxAttempts = curR <= 5 ? 5000 : (curR <= 6 ? 1000 : 300);

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final result = buildBoard(curR, curC, rand);
        if (result == null) continue;
        
        final (board, free) = result;
        if (free < bestFree) {
          bestFree = free;
          bestBoard = board;
        }
        if (free <= levelMaxFree) break;
      }

      // 폴백: 자유도 무제한
      while (bestBoard == null) {
        final result = buildBoard(curR, curC, rand);
        if (result != null) {
          bestBoard = result.$1;
          bestFree = result.$2;
        }
      }

      int n = bestBoard!.length;
      print("Level $gid: ${curR}x${curC} ($n arrows), $bestFree free (limit: $levelMaxFree)");

      buf.writeln("  // --- Level $gid ($bestFree free / $n arrows) ---");
      buf.writeln("  const LevelData(");
      buf.writeln("    id: $gid, chapter: $ch, rows: $curR, cols: $curC,");
      buf.writeln("    arrows: [");
      for (final a in bestBoard!) buf.writeln("      ArrowData(row: ${a.r}, col: ${a.c}, direction: ${a.dir.dartName}),");
      buf.writeln("    ],");
      buf.writeln("    par: $n,");
      buf.writeln("  ),\n");
      gid++;
    }
    buf.writeln("];\n");
  }

  buf.writeln("final List<LevelData> allLevels = [");
  for (final n in chapterNames) buf.writeln("  ...$n,");
  buf.writeln("];");

  File('lib/data/levels.dart').writeAsStringSync(buf.toString());
  print("\n✅ Generated ${gid - 1} FULL-DENSITY levels!");
}
