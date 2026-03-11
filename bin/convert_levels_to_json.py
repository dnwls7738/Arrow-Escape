"""
levels.dart → JSON 변환 스크립트
Dart 소스를 파싱하여 챕터별 JSON 파일 생성
실행: python bin/convert_levels_to_json.py
"""

import re
import json
import os

def parse_levels_dart(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 각 챕터의 레벨 목록을 찾기
    chapters = {}
    
    # LevelData 블록을 찾아서 파싱
    # const LevelData( id: X, chapter: Y, rows: R, cols: C, ... par: P, )
    level_pattern = re.compile(
        r'const\s+LevelData\(\s*'
        r'id:\s*(\d+),\s*chapter:\s*(\d+),\s*rows:\s*(\d+),\s*cols:\s*(\d+),\s*'
        r'paths:\s*\[(.*?)\],\s*'
        r'par:\s*(\d+),?\s*'
        r'(?:emptyCells:\s*\[(.*?)\],?\s*)?'
        r'\)',
        re.DOTALL
    )
    
    path_pattern = re.compile(
        r'PathData\(\s*id:\s*(\d+),\s*colorIndex:\s*(\d+),\s*segments:\s*\[(.*?)\]\s*\)',
        re.DOTALL
    )
    
    coord_pattern = re.compile(
        r'Coordinate\(\s*row:\s*(\d+),\s*col:\s*(\d+)\s*\)'
    )
    
    for match in level_pattern.finditer(content):
        level_id = int(match.group(1))
        chapter = int(match.group(2))
        rows = int(match.group(3))
        cols = int(match.group(4))
        paths_str = match.group(5)
        par = int(match.group(6))
        empty_cells_str = match.group(7)
        
        # Parse paths
        paths = []
        for path_match in path_pattern.finditer(paths_str):
            path_id = int(path_match.group(1))
            color_index = int(path_match.group(2))
            segments_str = path_match.group(3)
            
            segments = []
            for coord_match in coord_pattern.finditer(segments_str):
                segments.append({
                    'row': int(coord_match.group(1)),
                    'col': int(coord_match.group(2))
                })
            
            paths.append({
                'id': path_id,
                'colorIndex': color_index,
                'segments': segments
            })
        
        # Parse empty cells
        empty_cells = []
        if empty_cells_str:
            empty_cells = re.findall(r"'([^']+)'", empty_cells_str)
        
        level_data = {
            'id': level_id,
            'chapter': chapter,
            'rows': rows,
            'cols': cols,
            'paths': paths,
            'par': par,
            'emptyCells': empty_cells
        }
        
        if chapter not in chapters:
            chapters[chapter] = []
        chapters[chapter].append(level_data)
    
    return chapters


def main():
    filepath = 'lib/data/levels.dart'
    
    if not os.path.exists(filepath):
        print(f'Error: {filepath} not found')
        return
    
    print(f'Parsing {filepath}...')
    chapters = parse_levels_dart(filepath)
    
    # Create output directory
    os.makedirs('assets/levels', exist_ok=True)
    
    total_levels = 0
    for chapter_num in sorted(chapters.keys()):
        levels = chapters[chapter_num]
        # Sort by level id
        levels.sort(key=lambda x: x['id'])
        total_levels += len(levels)
        
        output_path = f'assets/levels/chapter_{chapter_num}.json'
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(levels, f, indent=2, ensure_ascii=False)
        
        file_size = os.path.getsize(output_path)
        print(f'  Chapter {chapter_num}: {len(levels)} levels → {output_path} ({file_size:,} bytes)')
    
    print(f'\n✅ Total: {total_levels} levels across {len(chapters)} chapters exported!')


if __name__ == '__main__':
    main()
