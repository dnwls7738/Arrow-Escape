#!/usr/bin/env python3
"""
Arrow Escape 퍼즐 생성기 - Dart 원본의 정확한 Python 포트
==========================================================
Dart 원본 알고리즘이 유일하게 작동하는 것으로 확인됨.
Python으로 포팅하여 실행 속도만 향상.
"""

import random
import math
import sys
import os

DIRS = [(-1, 0), (1, 0), (0, -1), (0, 1)]
DIR_NAMES = {(-1, 0): '↑', (1, 0): '↓', (0, -1): '←', (0, 1): '→'}


def fill_rectangle(rows, cols, num_paths, rng):
    """Dart fillRectangle 정확 포트 - Warnsdorff round-robin"""
    grid = [[-1] * cols for _ in range(rows)]
    chains = []

    cells = [(r, c) for r in range(rows) for c in range(cols)]
    rng.shuffle(cells)

    for i in range(num_paths):
        r, c = cells[i]
        grid[r][c] = i
        chains.append([(r, c)])

    filled = num_paths
    total = rows * cols
    stuck = 0

    while filled < total and stuck < 200:
        grew = False
        order = list(range(len(chains)))
        rng.shuffle(order)

        for i in order:
            if filled >= total:
                break
            r, c = chains[i][-1]

            # Turn bias 추가
            prev_dir = None
            if len(chains[i]) >= 2:
                pr, pc = chains[i][-2]
                prev_dir = (r - pr, c - pc)

            neighbors = []
            for dr, dc in DIRS:
                nr, nc = r + dr, c + dc
                if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] == -1:
                    deg = sum(
                        1 for dr2, dc2 in DIRS
                        if 0 <= nr + dr2 < rows and 0 <= nc + dc2 < cols
                        and grid[nr + dr2][nc + dc2] == -1
                    )
                    is_turn = prev_dir is not None and (dr, dc) != prev_dir
                    neighbors.append((nr, nc, deg, is_turn))

            if not neighbors:
                continue

            # Turn bias 60%
            want_turn = rng.random() < 0.6
            neighbors.sort(key=lambda x: (x[2], -int(x[3]) if want_turn else int(x[3])))

            best_deg = neighbors[0][2]
            cands = [n for n in neighbors if n[2] == best_deg]
            nr, nc, _, _ = rng.choice(cands)

            grid[nr][nc] = i
            chains[i].append((nr, nc))
            filled += 1
            grew = True

        if not grew:
            stuck += 1
        else:
            stuck = 0

    # 남은 빈칸 채우기
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] != -1:
                continue
            for dr, dc in DIRS:
                nr, nc = r + dr, c + dc
                if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] != -1:
                    pid = grid[nr][nc]
                    if chains[pid][-1] == (nr, nc):
                        chains[pid].append((r, c))
                        grid[r][c] = pid
                        break
                    elif chains[pid][0] == (nr, nc):
                        chains[pid].insert(0, (r, c))
                        grid[r][c] = pid
                        break

    # 검증
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == -1:
                return None
    for chain in chains:
        if len(chain) < 2:
            return None
    for chain in chains:
        for j in range(len(chain) - 1):
            if abs(chain[j][0] - chain[j + 1][0]) + abs(chain[j][1] - chain[j + 1][1]) != 1:
                return None
    # 겹침 검사
    seen = set()
    for chain in chains:
        for seg in chain:
            if seg in seen:
                return None
            seen.add(seg)

    return chains


def can_escape(chain, direction, my_id, grid, rows, cols):
    """Dart canEscape 정확 포트"""
    sim = list(chain)
    dr, dc = direction
    max_steps = rows * cols + len(chain) + 10

    for _ in range(max_steps):
        hr, hc = sim[-1]
        nr, nc = hr + dr, hc + dc

        if 0 <= nr < rows and 0 <= nc < cols:
            # 자가 충돌 (꼬리 제외)
            for k in range(1, len(sim)):
                if sim[k] == (nr, nc):
                    return False
            # 타 뱀 충돌
            cell = grid[nr][nc]
            if cell != -1 and cell != my_id:
                return False

        sim.append((nr, nc))
        sim.pop(0)

        if all(r < 0 or r >= rows or c < 0 or c >= cols for r, c in sim):
            return True

    return False


def orient_and_verify(chains, rows, cols, rng):
    """Dart orientAndVerify 정확 포트"""
    remaining = set(range(len(chains)))
    grid = [[-1] * cols for _ in range(rows)]
    for i, chain in enumerate(chains):
        for r, c in chain:
            grid[r][c] = i

    result = {}

    while remaining:
        escaped_id = None
        chosen_orient = None
        candidates = list(remaining)
        rng.shuffle(candidates)

        for sid in candidates:
            chain = chains[sid]

            # Option A: 그대로
            dir_a = (chain[-1][0] - chain[-2][0], chain[-1][1] - chain[-2][1])
            clear_a = can_escape(chain, dir_a, sid, grid, rows, cols)

            # Option B: 뒤집기
            rev = list(reversed(chain))
            dir_b = (rev[-1][0] - rev[-2][0], rev[-1][1] - rev[-2][1])
            clear_b = can_escape(rev, dir_b, sid, grid, rows, cols)

            if clear_a and clear_b:
                chosen_orient = list(chain) if rng.random() < 0.5 else rev
            elif clear_a:
                chosen_orient = list(chain)
            elif clear_b:
                chosen_orient = rev

            if chosen_orient is not None:
                escaped_id = sid
                break

        if escaped_id is None:
            # 교착: 뱀 분할
            split_done = False
            for sid in candidates:
                chain = chains[sid]
                if len(chain) >= 4:
                    mid = len(chain) // 2
                    c1 = chain[:mid]
                    c2 = chain[mid:]
                    chains[sid] = c1
                    new_id = len(chains)
                    chains.append(c2)
                    for r2, c2s in c2:
                        grid[r2][c2s] = new_id
                    remaining.add(new_id)
                    split_done = True
                    break
            if not split_done:
                return None
            continue

        for r, c in chains[escaped_id]:
            grid[r][c] = -1
        remaining.remove(escaped_id)
        
        dr = chosen_orient[-1][0] - chosen_orient[-2][0]
        dc = chosen_orient[-1][1] - chosen_orient[-2][1]
        result[escaped_id] = {
            'id': escaped_id + 1,
            'color': escaped_id % 8,
            'segs': chosen_orient,
            'dir': (dr, dc),
        }

    paths = list(result.values())

    # 시각적 직관성 검사 (30개 미만만)
    if len(paths) < 30:
        for p in paths:
            segs = p['segs']
            if len(segs) < 2:
                continue
            hr, hc = segs[-1]
            dr, dc = p['dir']
            face = (hr + dr, hc + dc)

            if face in set(segs):
                return None

            for other in paths:
                if other['id'] == p['id'] or len(other['segs']) < 2:
                    continue
                oh = other['segs'][-1]
                if face == oh:
                    odr = other['segs'][-1][0] - other['segs'][-2][0]
                    odc = other['segs'][-1][1] - other['segs'][-2][1]
                    oface = (oh[0] + odr, oh[1] + odc)
                    if oface == (hr, hc):
                        return None

    return paths


def generate_level(target_paths, rng):
    """레벨 생성"""
    is_hard = target_paths > 60
    base_cpp = 12.0 if is_hard else 10.0

    for attempt in range(5000):
        expansion = 1.0 + (attempt // 500) * 0.02
        cpp = base_cpp * expansion
        area = int(target_paths * cpp)

        ratio = 0.8 + rng.random() * 0.4
        cols = max(4, round(math.sqrt(area * ratio)))
        rows = max(4, round(area / cols))

        min_ratio = 5.0 if target_paths > 200 else (4.0 if target_paths > 100 else 3.0)
        if rows * cols < target_paths * min_ratio:
            rows = round(rows * 1.3)
            cols = round(cols * 1.3)

        chains = fill_rectangle(rows, cols, target_paths, rng)
        if chains is None:
            continue

        paths = orient_and_verify(chains, rows, cols, rng)
        if paths is not None:
            # 평균 길이 검사 (30개 미만)
            if len(paths) < 30:
                avg = sum(len(p['segs']) for p in paths) / len(paths)
                if avg < 4.0:
                    continue

            return rows, cols, paths

    return None


def gen_dart(ch_id, ch_num, rows, cols, arrows):
    lines = [f'  // {rows}×{cols}, {len(arrows)} paths']
    lines.append(f'  const LevelData(')
    lines.append(f'    id: {ch_id}, chapter: {ch_num}, rows: {rows}, cols: {cols},')
    lines.append(f'    paths: [')
    for a in arrows:
        lines.append(f'      PathData(id: {a["id"]}, colorIndex: {a["color"]}, segments: [')
        for r, c in a['segs']:
            lines.append(f'        Coordinate(row: {r}, col: {c}),')
        lines.append(f'      ]),')
    lines.append(f'    ],')
    lines.append(f'    par: {len(arrows)},')
    lines.append(f'  ),')
    return '\n'.join(lines)


def main():
    rng = random.Random()
    rp = lambda lo, hi: rng.randint(lo, hi)

    LEVELS_PER_CHAPTER = 20

    # 각 난이도의 화살표 수 범위 (레벨마다 랜덤)
    difficulty_ranges = [
        {'name': '쉬움',       'ch': 1, 'lo': 5,   'hi': 10},
        {'name': '보통',       'ch': 2, 'lo': 15,  'hi': 25},
        {'name': '어려움',     'ch': 3, 'lo': 30,  'hi': 50},
        {'name': '매우어려움', 'ch': 4, 'lo': 60,  'hi': 90},
    ]

    code = ["import '../models/level_data.dart';", "import '../core/constants.dart';", ""]

    global_id = 1  # 전체 레벨 ID (1~80)

    for di, diff in enumerate(difficulty_ranges):
        cn = di + 1
        print(f"\n{'='*50}", file=sys.stderr)
        print(f"📦 Chapter {cn} - {diff['name']} ({LEVELS_PER_CHAPTER}개 생성 중...)", file=sys.stderr)
        print(f"{'='*50}", file=sys.stderr)

        code.append(f"/// Chapter {cn} - {diff['name']}")
        code.append(f"final List<LevelData> chapter{cn}Levels = [")

        for level_idx in range(LEVELS_PER_CHAPTER):
            target = rp(diff['lo'], diff['hi'])
            orig = target

            print(f"  🎯 [{level_idx+1}/{LEVELS_PER_CHAPTER}] {diff['name']} ({target}p): ",
                  end='', flush=True, file=sys.stderr)

            result = None
            outer = 0
            while result is None:
                result = generate_level(target, rng)
                outer += 1
                if outer % 3 == 0:
                    print('.', end='', flush=True, file=sys.stderr)
                if result is None and outer % 10 == 0 and target > 10:
                    reduced = max(10, int(target * 0.9))
                    print(f"\n     ⚠️ {target}→{reduced}", file=sys.stderr, flush=True)
                    print('     ', end='', file=sys.stderr, flush=True)
                    target = reduced

            rows, cols, arrows = result
            ds = {'↑': 0, '↓': 0, '←': 0, '→': 0}
            for a in arrows:
                ds[DIR_NAMES.get(a['dir'], '?')] = ds.get(DIR_NAMES.get(a['dir'], '?'), 0) + 1
            adj = f" (adj {orig}→{target})" if target != orig else ""
            print(f" ✓ {rows}×{cols} {len(arrows)}p{adj}", file=sys.stderr)

            code.append(gen_dart(global_id, cn, rows, cols, arrows))
            global_id += 1

        code.append("];")
        code.append("")

    # Chapter 5 - Coming Soon (빈 리스트)
    code.append("/// Chapter 5 - 악몽 (Coming Soon)")
    code.append("final List<LevelData> chapter5Levels = [];")
    code.append("")

    with open(os.path.join('lib', 'data', 'levels.dart'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(code) + '\n')

    print(f"\n✅ Done! {global_id - 1}개 레벨 생성 완료!", file=sys.stderr)


if __name__ == '__main__':
    main()

