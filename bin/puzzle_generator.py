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
import concurrent.futures
from itertools import groupby

DIRS = [(-1, 0), (1, 0), (0, -1), (0, 1)]
DIR_NAMES = {(-1, 0): '↑', (1, 0): '↓', (0, -1): '←', (0, 1): '→'}

MASKS_ASCII = {
    'heart': [
        "  ██  ██  ",
        " ████████ ",
        "██████████",
        "██████████",
        " ████████ ",
        "  ██████  ",
        "   ████   ",
        "    ██    "
    ],
    'cross': [
        "   ████   ",
        "   ████   ",
        "   ████   ",
        "██████████",
        "██████████",
        "██████████",
        "   ████   ",
        "   ████   ",
        "   ████   "
    ],
    'diamond': [
        "    ██    ",
        "   ████   ",
        "  ██████  ",
        " ████████ ",
        "██████████",
        " ████████ ",
        "  ██████  ",
        "   ████   ",
        "    ██    "
    ],
    'spaceship': [
        "    ██    ",
        "   ████   ",
        "  ██████  ",
        "  ██████  ",
        "██████████",
        "██████████",
        " ██ ██ ██ ",
        " ██    ██ "
    ],
    'skull': [
        "   ████   ",
        "  ██████  ",
        " ████████ ",
        " ██ ██ ██ ",
        " ████████ ",
        "  ██  ██  ",
        "   ████   "
    ],
    'star': [
        "    ██    ",
        "   ████   ",
        "██████████",
        " ████████ ",
        "  ██████  ",
        "  ██  ██  ",
        " ██    ██ "
    ],
    'house': [
        "    ██    ",
        "   ████   ",
        "  ██████  ",
        " ████████ ",
        "██████████",
        " ████████ ",
        " ████████ ",
        " ████████ "
    ],
    'triangle': [
        "     ██     ",
        "    ████    ",
        "   ██████   ",
        "  ████████  ",
        " ██████████ ",
        "████████████"
    ],
    'hourglass': [
        "██████████",
        " ████████ ",
        "  ██████  ",
        "   ████   ",
        "    ██    ",
        "   ████   ",
        "  ██████  ",
        " ████████ ",
        "██████████"
    ],
    'mushroom': [
        "   ████   ",
        "  ██████  ",
        " ████████ ",
        "██████████",
        "  ██████  ",
        "   ████   ",
        "   ████   "
    ]
}

def scale_mask(ascii_mask, target_area):
    orig_rows = len(ascii_mask)
    orig_cols = max(len(r) for r in ascii_mask)
    
    orig_ones = sum(c != ' ' for r in ascii_mask for c in r)
    scale_factor = math.sqrt(target_area / max(1, orig_ones))
    
    new_rows = max(4, round(orig_rows * scale_factor))
    new_cols = max(4, round(orig_cols * scale_factor))
    
    mask = [[0] * new_cols for _ in range(new_rows)]
    for r in range(new_rows):
        for c in range(new_cols):
            orig_r = min(orig_rows - 1, int(r / scale_factor))
            orig_c = min(orig_cols - 1, int(c / scale_factor))
            
            if orig_c < len(ascii_mask[orig_r]) and ascii_mask[orig_r][orig_c] != ' ':
                mask[r][c] = 1
                
    return new_rows, new_cols, mask


def fill_rectangle(rows, cols, num_paths, rng, mask_grid=None):
    """Dart fillRectangle 정확 포트 - Warnsdorff round-robin"""
    grid = [[-1] * cols for _ in range(rows)]
    if mask_grid:
        for r in range(rows):
            for c in range(cols):
                if mask_grid[r][c] == 0:
                    grid[r][c] = -2  # 벽 처리
                    
    chains = []

    cells = [(r, c) for r in range(rows) for c in range(cols) if grid[r][c] == -1]
    
    if len(cells) < num_paths:
        return None
        
    rng.shuffle(cells)

    for i in range(num_paths):
        r, c = cells[i]
        grid[r][c] = i
        chains.append([(r, c)])

    filled = num_paths
    total = len(cells)
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
            if cell >= 0 and cell != my_id:
                return False

        sim.append((nr, nc))
        sim.pop(0)

        if all(r < 0 or r >= rows or c < 0 or c >= cols for r, c in sim):
            return True

    return False


def orient_and_verify(chains, rows, cols, rng, mask_grid=None):
    """Dart orientAndVerify 정확 포트"""
    remaining = set(range(len(chains)))
    grid = [[-1] * cols for _ in range(rows)]
    for i, chain in enumerate(chains):
        for r, c in chain:
            grid[r][c] = i
            
    if mask_grid:
        for r in range(rows):
            for c in range(cols):
                if mask_grid[r][c] == 0:
                    grid[r][c] = -2

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

    # 1. 자가 교착 오류 방지 검사 (모든 난이도 / 모든 경로 개수에서 필수 적용)
    # 화살표 머리가 자기 자신의 꼬리(몸통)를 바라보고 있으면 풀 수 없게 되므로 엄격하게 타파
    for p in paths:
        segs = p['segs']
        if len(segs) < 2:
            continue
        hr, hc = segs[-1]
        dr, dc = p['dir']
        face = (hr + dr, hc + dc)
        
        if face in set(segs):
            return None

    # 2. 시각적 직관성 및 마주보기 교착 방지 검사 (경로 30개 미만인 비교적 널널한 맵에서 적용)
    if len(paths) < 30:
        for p in paths:
            segs = p['segs']
            if len(segs) < 2:
                continue
            hr, hc = segs[-1]
            dr, dc = p['dir']
            face = (hr + dr, hc + dc)

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


def generate_level(target_paths, rng, mask_type=None):
    """레벨 생성"""
    is_hard = target_paths > 60
    base_cpp = 12.0 if is_hard else 10.0

    for attempt in range(5000):
        expansion = 1.0 + (attempt // 500) * 0.02
        cpp = base_cpp * expansion
        area = int(target_paths * cpp)

        if mask_type and mask_type in MASKS_ASCII:
            rows, cols, mask_grid = scale_mask(MASKS_ASCII[mask_type], area)
        else:
            ratio = 0.8 + rng.random() * 0.4
            cols = max(4, round(math.sqrt(area * ratio)))
            rows = max(4, round(area / cols))
            mask_grid = None

        if mask_grid is None:
            min_ratio = 5.0 if target_paths > 200 else (4.0 if target_paths > 100 else 3.0)
            if rows * cols < target_paths * min_ratio:
                rows = round(rows * 1.3)
                cols = round(cols * 1.3)

        chains = fill_rectangle(rows, cols, target_paths, rng, mask_grid)
        if chains is None:
            continue

        paths = orient_and_verify(chains, rows, cols, rng, mask_grid)
        if paths is not None:
            # 평균 길이 검사 (30개 미만)
            if len(paths) < 30:
                avg = sum(len(p['segs']) for p in paths) / len(paths)
                if avg < 4.0:
                    continue
            
            empty_cells = []
            if mask_grid:
                for r in range(rows):
                    for c in range(cols):
                        if mask_grid[r][c] == 0:
                            empty_cells.append(f"{r}_{c}")

            return rows, cols, paths, empty_cells

    return None


def gen_dart(ch_id, ch_num, rows, cols, arrows, empty_cells):
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
    
    if empty_cells:
        formatted_cells = ', '.join([f"'{cell}'" for cell in empty_cells])
        lines.append(f'    emptyCells: [{formatted_cells}],')
        
    lines.append(f'  ),')
    return '\n'.join(lines)


def generate_level_worker(task):
    global_id = task['global_id']
    cn = task['cn']
    target = task['target']
    orig_target = target
    seed = task['seed']
    diff_name = task['diff_name']
    level_idx = task['level_idx']
    mask_type = task.get('mask_type')
    
    rng = random.Random(seed)
    
    result = None
    outer = 0
    while result is None:
        result = generate_level(target, rng, mask_type)
        outer += 1
        if result is None and outer % 10 == 0 and target > 10:
            target = max(10, int(target * 0.9))
            
    rows, cols, arrows, empty_cells = result
    dart_code = gen_dart(global_id, cn, rows, cols, arrows, empty_cells)
    
    return {
        'global_id': global_id,
        'cn': cn,
        'diff_name': diff_name,
        'level_idx': level_idx,
        'orig_target': orig_target,
        'final_target': target,
        'rows': rows,
        'cols': cols,
        'dart_code': dart_code,
        'arrows': arrows
    }


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
        {'name': '악몽',       'ch': 5, 'lo': 60,  'hi': 90, 'special': True},
    ]

    print("🚀 퍼즐 생성을 시작합니다... (특수 도형 및 멀티프로세싱 도입)", file=sys.stderr)

    tasks = []
    global_id = 1
    for diff in difficulty_ranges:
        cn = diff['ch']
        for level_idx in range(LEVELS_PER_CHAPTER):
            target = rp(diff['lo'], diff['hi'])
            
            mask_type = None
            if diff.get('special'):
                mask_type = rng.choice(list(MASKS_ASCII.keys()))
                
            tasks.append({
                'global_id': global_id,
                'cn': cn,
                'diff_name': diff['name'],
                'target': target,
                'level_idx': level_idx,
                'seed': rng.randint(0, 2**32 - 1),
                'mask_type': mask_type
            })
            global_id += 1

    results = []
    # 프로세스 기반 병렬 처리
    with concurrent.futures.ProcessPoolExecutor() as executor:
        future_to_task = {executor.submit(generate_level_worker, t): t for t in tasks}
        for future in concurrent.futures.as_completed(future_to_task):
            res = future.result()
            results.append(res)
            # 완료된 작업 출력
            adj = f" (adj {res['orig_target']}→{res['final_target']})" if res['final_target'] != res['orig_target'] else ""
            print(f" ✓ [Ch {res['cn']} - {res['diff_name']}] #{res['level_idx']+1} : {res['rows']}×{res['cols']} {len(res['arrows'])}p{adj}", file=sys.stderr)

    # global_id 순으로 결과 정렬
    results.sort(key=lambda x: x['global_id'])

    code = ["import '../models/level_data.dart';", "import '../core/constants.dart';", ""]

    for cn, group in groupby(results, key=lambda x: x['cn']):
        diff_name = next((d['name'] for d in difficulty_ranges if d['ch'] == cn), "Unknown")
        code.append(f"/// Chapter {cn} - {diff_name}")
        code.append(f"final List<LevelData> chapter{cn}Levels = [")
        for res in group:
            code.append(res['dart_code'])
        code.append("];")
        code.append("")



    # 절대 경로 계산 (bin/puzzle_generator.py -> .. -> lib/data/levels.dart)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_path = os.path.join(project_root, 'lib', 'data', 'levels.dart')
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(code) + '\n')

    print(f"\n✅ Done! {global_id - 1}개 레벨 생성 완료!", file=sys.stderr)
    print(f"💾 저장 경로: {output_path}", file=sys.stderr)


if __name__ == '__main__':
    main()

