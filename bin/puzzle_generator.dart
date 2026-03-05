import 'dart:math';
import 'dart:io';

/// 퍼즐 레벨 자동 생성기 - 완전 재작성 (Clean Rewrite)
/// 
/// 핵심 원칙:
/// 1. 직사각형을 100% 빈틈없이 채움 (두들아트)
/// 2. 대각선 절대 금지 (상하좌우만)
/// 3. 겹침 절대 금지
/// 4. 화살표가 다른 화살표를 감싸는 구조 OK
/// 5. 풀 수 있어야 함 (위상 정렬)

class Coord {
  final int row, col;
  const Coord(this.row, this.col);
  @override
  bool operator ==(Object o) => o is Coord && row == o.row && col == o.col;
  @override
  int get hashCode => Object.hash(row, col);
}

const _dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];

/// ========== 1단계: 직사각형 100% 채우기 ==========
/// Warnsdorff 규칙으로 뱀들을 한쪽 끝에서만 성장시켜 빈칸 없이 채움
List<List<Coord>>? fillRectangle(int rows, int cols, int numPaths, Random rng) {
  final grid = List.generate(rows, (_) => List.filled(cols, -1));
  final chains = <List<Coord>>[];
  
  // 씨앗 배치
  final allCells = <Coord>[];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      allCells.add(Coord(r, c));
    }
  }
  allCells.shuffle(rng);
  
  for (int i = 0; i < numPaths; i++) {
    final seed = allCells[i];
    grid[seed.row][seed.col] = i;
    chains.add([seed]);
  }
  
  int filled = numPaths;
  final total = rows * cols;
  int stuckCount = 0;
  
  while (filled < total && stuckCount < 200) {
    bool grew = false;
    final order = List.generate(chains.length, (i) => i)..shuffle(rng);
    
    for (final i in order) {
      if (filled >= total) break;
      final chain = chains[i];
      final end = chain.last;
      
      // 인접한 빈칸 찾기
      final neighbors = <(Coord, int, bool)>[]; // Coord, degree, isTurn
      final currentDir = chain.length < 2 
          ? null 
          : (chain.last.row - chain[chain.length - 2].row, chain.last.col - chain[chain.length - 2].col);

      for (final (dr, dc) in _dirs) {
        final nr = end.row + dr, nc = end.col + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] == -1) {
          int deg = 0;
          for (final (dr2, dc2) in _dirs) {
            final nnr = nr + dr2, nnc = nc + dc2;
            if (nnr >= 0 && nnr < rows && nnc >= 0 && nnc < cols && grid[nnr][nnc] == -1) deg++;
          }
          final isTurn = currentDir != null && (dr != currentDir.$1 || dc != currentDir.$2);
          neighbors.add((Coord(nr, nc), deg, isTurn));
        }
      }
      
      if (neighbors.isEmpty) continue;
      
      // U자 형태를 위해 '꺾기(Turn)' 선호 (60% 확률로 꺾기 선호)
      final wantTurn = rng.nextDouble() < 0.6;
      
      neighbors.sort((a, b) {
        // 1순위: Warnsdorff (degree가 낮을수록 좋음 - 고립 방지)
        int cmp = a.$2.compareTo(b.$2);
        if (cmp != 0) return cmp;
        
        // 2순위: 꺾기 선호 여부
        if (wantTurn) {
          if (a.$3 && !b.$3) return -1;
          if (!a.$3 && b.$3) return 1;
        } else {
          if (!a.$3 && b.$3) return -1;
          if (a.$3 && !b.$3) return 1;
        }
        return 0;
      });
      
      final bestDeg = neighbors.first.$2;
      final candidates = neighbors.where((n) => n.$2 == bestDeg).toList();
      final chosen = candidates[rng.nextInt(candidates.length)].$1;
      
      grid[chosen.row][chosen.col] = i;
      chain.add(chosen);
      filled++;
      grew = true;
    }
    
    if (!grew) stuckCount++;
    else stuckCount = 0;
  }
  
  // 남은 빈칸을 인접한 체인의 끝에 붙여서 강제 채움
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (grid[r][c] != -1) continue;
      final cell = Coord(r, c);
      
      // 인접한 체인의 머리(last)나 꼬리(first)에 붙일 수 있는지 확인
      for (final (dr, dc) in _dirs) {
        final nr = r + dr, nc = c + dc;
        if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
        final pid = grid[nr][nc];
        if (pid == -1) continue;
        
        final chain = chains[pid];
        if (chain.last == Coord(nr, nc)) {
          chain.add(cell);
          grid[r][c] = pid;
          break;
        } else if (chain.first == Coord(nr, nc)) {
          chain.insert(0, cell);
          grid[r][c] = pid;
          break;
        }
      }
    }
  }
  
  // 그래도 남은 빈칸이 있으면 체인 중간에 끼워넣기 (분할)
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (grid[r][c] != -1) continue;
      final cell = Coord(r, c);
      
      bool fixed = false;
      for (final (dr, dc) in _dirs) {
        if (fixed) break;
        final nr = r + dr, nc = c + dc;
        if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
        final pid = grid[nr][nc];
        if (pid == -1) continue;
        
        final chain = chains[pid];
        if (chain.length < 3) continue;
        
        // chain 안에서 nr,nc의 위치 찾기
        for (int j = 0; j < chain.length; j++) {
          if (chain[j] == Coord(nr, nc)) {
            // j 위치에서 분할: [0..j] + cell, [j+1..end]
            if (j > 0 && j < chain.length - 1) {
              final part1 = chain.sublist(0, j + 1);
              part1.add(cell);
              final part2 = chain.sublist(j + 1);
              
              if (part2.length >= 2) {
                chains[pid] = part1;
                final newId = chains.length;
                chains.add(part2);
                for (final s in part1) grid[s.row][s.col] = pid;
                for (final s in part2) grid[s.row][s.col] = newId;
                grid[r][c] = pid;
                fixed = true;
                break;
              }
            }
          }
        }
      }
    }
  }
  
  // === 검증 ===
  // 1. 빈칸이 없는지
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (grid[r][c] == -1) return null;
    }
  }
  
  // 2. 모든 체인 길이 >= 2
  for (final chain in chains) {
    if (chain.length < 2) return null;
  }
  
  // 3. 모든 연결이 상하좌우 인접인지 (대각선 검출)
  for (final chain in chains) {
    for (int i = 0; i < chain.length - 1; i++) {
      final a = chain[i], b = chain[i + 1];
      final dist = (a.row - b.row).abs() + (a.col - b.col).abs();
      if (dist != 1) return null; // 대각선 또는 점프 발견!!
    }
  }
  
  // 4. 겹침 검사
  final seen = <Coord>{};
  for (final chain in chains) {
    for (final seg in chain) {
      if (seen.contains(seg)) return null; // 겹침 발견!!
      seen.add(seg);
    }
  }
  
  return chains;
}

/// ========== 2단계: 풀이 가능성 보장 (위상 정렬) ==========
/// 게임의 실제 이동 로직과 동일한 시뮬레이션으로 탈출 가능성 검사
class PathInfo {
  final int id;
  final int colorIndex;
  final List<Coord> segments;
  PathInfo(this.id, this.colorIndex, this.segments);
  
  (int, int) get headDirection {
    final last = segments.last;
    final prev = segments[segments.length - 2];
    return (last.row - prev.row, last.col - prev.col);
  }
}

bool canEscape(List<Coord> chain, (int, int) dir, int myId, List<List<int>> grid, int rows, int cols) {
  var sim = List<Coord>.from(chain);
  final maxSteps = rows * cols + chain.length + 10;
  
  for (int step = 0; step < maxSteps; step++) {
    final head = sim.last;
    final nh = Coord(head.row + dir.$1, head.col + dir.$2);
    
    if (nh.row >= 0 && nh.row < rows && nh.col >= 0 && nh.col < cols) {
      // 자가 충돌 (꼬리 제외)
      for (int i = 1; i < sim.length; i++) {
        if (sim[i] == nh) return false;
      }
      // 타 뱀 충돌
      final cell = grid[nh.row][nh.col];
      if (cell != -1 && cell != myId) return false;
    }
    
    sim.add(nh);
    sim.removeAt(0);
    
    // 보드 밖으로 완전히 나갔는지
    if (sim.every((s) => s.row < 0 || s.row >= rows || s.col < 0 || s.col >= cols)) {
      return true;
    }
  }
  return false;
}

List<PathInfo>? orientAndVerify(List<List<Coord>> chains, int rows, int cols, Random rng) {
  final remaining = Set<int>.from(Iterable.generate(chains.length));
  final grid = List.generate(rows, (_) => List.filled(cols, -1));
  for (int i = 0; i < chains.length; i++) {
    for (final seg in chains[i]) grid[seg.row][seg.col] = i;
  }
  
  final result = <int, PathInfo>{};
  
  while (remaining.isNotEmpty) {
    int? escapedId;
    List<Coord>? chosenOrient;
    final candidates = remaining.toList()..shuffle(rng);
    
    for (final id in candidates) {
      final chain = chains[id];
      
      // Option A: chain 그대로 (last가 head)
      final dirA = (chain.last.row - chain[chain.length - 2].row,
                     chain.last.col - chain[chain.length - 2].col);
      final clearA = canEscape(chain, dirA, id, grid, rows, cols);
      
      // Option B: 뒤집기 (first가 head)
      final rev = chain.reversed.toList();
      final dirB = (rev.last.row - rev[rev.length - 2].row,
                     rev.last.col - rev[rev.length - 2].col);
      final clearB = canEscape(rev, dirB, id, grid, rows, cols);
      
      if (clearA && clearB) {
        chosenOrient = rng.nextBool() ? List.from(chain) : rev;
      } else if (clearA) {
        chosenOrient = List.from(chain);
      } else if (clearB) {
        chosenOrient = rev;
      }
      
      if (chosenOrient != null) {
        escapedId = id;
        break;
      }
    }
    
    if (escapedId == null) {
      // 교착 상태! 뱀 하나를 분할하여 의존성을 끊음
      bool splitted = false;
      for (final id in candidates) {
        final chain = chains[id];
        if (chain.length >= 4) {
          int mid = chain.length ~/ 2;
          final c1 = chain.sublist(0, mid);
          final c2 = chain.sublist(mid);
          
          chains[id] = c1;
          
          final newId = chains.length;
          chains.add(c2);
          for (final seg in c2) grid[seg.row][seg.col] = newId;
          
          remaining.add(newId);
          splitted = true;
          break;
        }
      }
      if (splitted) continue;
      
      // 쪼갤수도 없으면 재생성
      return null;
    }
    
    for (final seg in chains[escapedId]) grid[seg.row][seg.col] = -1;
    remaining.remove(escapedId);
    result[escapedId] = PathInfo(escapedId + 1, escapedId % 8, chosenOrient!);
  }
  
  final finalPaths = result.values.toList();
  
  // === 시각적 직관성 검사 (Visual Sanity) ===
  // 1. 자기 몸통/꼬리를 향해 바라보는 화살표 금지 (시각적 루프 방지)
  // 2. 다른 화살표 머리와 정면으로 마주보는 것 금지
  for (final p in finalPaths) {
    if (p.segments.length < 2) continue;
    final head = p.segments.last;
    final (dr, dc) = p.headDirection;
    final faceCoord = Coord(head.row + dr, head.col + dc);
    
    // 규칙 1: 자기 몸통 향해 바라보기 금지 (거리가 1칸 앞이 내 몸통이면 실패)
    for (final seg in p.segments) {
      if (seg == faceCoord) return null; // 자기 몸통(또는 꼬리)을 정면으로 봄
    }
    
    // 규칙 2: 다른 머리와 마주보기 금지
    for (final other in finalPaths) {
      if (other.id == p.id || other.segments.length < 2) continue;
      final otherHead = other.segments.last;
      
      if (faceCoord == otherHead) {
        final (odr, odc) = other.headDirection;
        final otherFaceCoord = Coord(otherHead.row + odr, otherHead.col + odc);
        if (otherFaceCoord == head) {
          return null; // A머리는 B머리를, B머리는 A머리를 정확히 마주봄
        }
      }
    }
  }
  
  // === 복잡도 및 포옹(Embracement) 점수 검사 ===
  // 1. 평균 길이 검사
  double avgLen = finalPaths.fold(0.0, (sum, p) => sum + p.segments.length) / finalPaths.length;
  if (avgLen < 6.0) return null; // 너무 짧으면 기각
  
  // 2. 굴곡(Coiling) 및 포옹 점수
  int embraceCount = 0;
  for (final p in finalPaths) {
    if (p.segments.length < 4) continue;
    
    final head = p.segments.last;
    final tail = p.segments.first;
    final manhattan = (head.row - tail.row).abs() + (head.col - tail.col).abs();
    // 꼬리와 머리가 가까움 = 둥글게 말려있음
    if (manhattan < p.segments.length / 2.3) {
      embraceCount++;
    }
  }
  
  // 60개 이상의 경로는 자연스럽게 얽히므로 포옹 검사 생략
  if (finalPaths.length < 60) {
    double requiredRatio = 0.15;
    if (finalPaths.length > 30) requiredRatio = 0.10;
    
    if (embraceCount < finalPaths.length * requiredRatio) return null;
  }
  
  return finalPaths;
}

/// ========== 3단계: 레벨 생성 ==========
List<PathInfo>? generateLevel(int targetPaths, Random rng, Map<String, dynamic> config) {
  // 기본 설정: 면적 및 뱀 길이
  final isHard = targetPaths > 60;
  final baseCellsPerPath = isHard ? 12.0 : 10.0;
  
  // 성공할 때까지 파라미터를 점진적으로 조정하며 반복
  for (int attempt = 0; attempt < 500; attempt++) {
    // 500번 실패할 때마다 면적(여유 공간)을 2%씩 넓혀서 난이도 타협
    final expansion = 1.0 + (attempt ~/ 500) * 0.02;
    final currentCellsPerPath = baseCellsPerPath * expansion;
    final area = (targetPaths * currentCellsPerPath).round();

    // 다양한 비율의 직사각형 시도
    int cols, rows;
    final ratio = 0.8 + rng.nextDouble() * 0.4; // 0.8 ~ 1.2
    cols = max(4, sqrt(area * ratio).round());
    rows = max(4, (area / cols).round());
    
    // 면적이 부족하면 최소한의 여유 확보
    // 경로가 많아질수록(매우 어려운/악몽) topological sorting이 막힐 확률이 높으므로 여유 공간을 더 줌
    final minAreaRatio = targetPaths > 200 ? 5.0 : (targetPaths > 100 ? 4.0 : 3.0);
    if (rows * cols < targetPaths * minAreaRatio) { 
      rows = (rows * 1.5).round(); 
      cols = (cols * 1.5).round(); 
    }
    
    final chains = fillRectangle(rows, cols, targetPaths, rng);
    if (chains == null) continue;
    
    // 경로가 분할되어 늘어났을 수 있으므로 실제 수 확인
    final actualPaths = chains.length;
    
    final paths = orientAndVerify(chains, rows, cols, rng);
    if (paths != null) {
      config['rows'] = rows;
      config['cols'] = cols;
      
      // 방향 통계
      final d = {'↑': 0, '↓': 0, '←': 0, '→': 0};
      for (final p in paths) {
        final (dr, dc) = p.headDirection;
        if (dr == -1) d['↑'] = d['↑']! + 1;
        if (dr == 1) d['↓'] = d['↓']! + 1;
        if (dc == -1) d['←'] = d['←']! + 1;
        if (dc == 1) d['→'] = d['→']! + 1;
      }
      stderr.writeln(' ✓ [Att ${attempt + 1}] ${rows}×${cols} ${paths.length}paths Dirs:$d');
      return paths;
    }
  }
  return null;
}

/// ========== 출력 ==========
String generateDartCode(Map<String, dynamic> config, List<PathInfo> paths) {
  final buf = StringBuffer();
  buf.writeln('  // ${config['name']} (${config['rows']}×${config['cols']}, ${paths.length} paths)');
  buf.writeln('  const LevelData(');
  buf.writeln('    id: ${config['id']}, chapter: ${config['chapter']}, rows: ${config['rows']}, cols: ${config['cols']},');
  buf.writeln('    paths: [');
  for (final path in paths) {
    buf.writeln('      PathData(id: ${path.id}, colorIndex: ${path.colorIndex}, segments: [');
    for (final seg in path.segments) {
      buf.writeln('        Coordinate(row: ${seg.row}, col: ${seg.col}),');
    }
    buf.writeln('      ]),');
  }
  buf.writeln('    ],');
  buf.writeln('    par: ${paths.length},');
  buf.writeln('  ),');
  return buf.toString();
}

void main() {
  final rng = Random();
  int rp(int lo, int hi) => lo + rng.nextInt(hi - lo + 1);
  
  final difficulties = [
    {'name': '쉬움',       'id': 1, 'chapter': 1, 'paths': rp(5, 10)},
    {'name': '보통',       'id': 2, 'chapter': 2, 'paths': rp(15, 35)},
    {'name': '어려움',     'id': 3, 'chapter': 3, 'paths': rp(40, 65)},
    {'name': '매우어려움', 'id': 4, 'chapter': 4, 'paths': rp(100, 150)},
    {'name': '악몽',       'id': 5, 'chapter': 5, 'paths': rp(250, 400)},
  ];
  
  final allLevelCode = StringBuffer();
  allLevelCode.writeln("import '../models/level_data.dart';");
  allLevelCode.writeln("import '../core/constants.dart';");
  allLevelCode.writeln();
  
  for (int di = 0; di < difficulties.length; di++) {
    final diff = difficulties[di];
    final cn = di + 1;
    int targetPaths = diff['paths'] as int;
    final originalTarget = targetPaths;
    
    stderr.write('\n🎯 ${diff['name']} ($targetPaths paths): ');
    
    List<PathInfo>? paths;
    int outerAttempts = 0;
    
    // 성공할 때까지 반복하되, 매우어려움/악몽은 화살표 수를 점진적으로 줄여가며 시도
    while (paths == null) {
      paths = generateLevel(targetPaths, rng, diff);
      outerAttempts++;
      
      if (outerAttempts % 100 == 0) {
        stderr.write('.');
      }
      
      // 200번 실패 시: 화살표 수를 10% 줄이고 재시도
      if (paths == null && outerAttempts % 200 == 0 && targetPaths > 30) {
        final reduced = (targetPaths * 0.9).round();
        stderr.write('\n   ⚠️ $outerAttempts attempts failed. Reducing paths: $targetPaths → $reduced\n   ');
        targetPaths = reduced;
        diff['paths'] = targetPaths;
      }
    }
    
    if (targetPaths != originalTarget) {
      stderr.write(' (adjusted from $originalTarget to $targetPaths)');
    }
    
    allLevelCode.writeln('/// Chapter $cn - ${diff['name']}');
    allLevelCode.writeln('final List<LevelData> chapter${cn}Levels = [');
    allLevelCode.writeln(generateDartCode(diff, paths));
    allLevelCode.writeln('];');
    allLevelCode.writeln();
  }
  
  File('lib/data/levels.dart').writeAsStringSync(allLevelCode.toString());
  stderr.writeln('\n✅ Done!');
}
