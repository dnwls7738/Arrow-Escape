// levels.dart → JSON 변환 스크립트
// 실행: dart run bin/export_levels_json.dart
// (프로젝트 루트에서 실행할 것)

import 'dart:convert';
import 'dart:io';
import '../lib/data/levels.dart';

void main() {
  final chapters = [
    chapter1Levels,
    chapter2Levels,
    chapter3Levels,
    chapter4Levels,
    chapter5Levels,
  ];

  final dir = Directory('assets/levels');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('Created directory: assets/levels/');
  }

  for (int i = 0; i < chapters.length; i++) {
    final chapterNum = i + 1;
    final levels = chapters[i];
    
    final jsonList = levels.map((level) {
      return {
        'id': level.id,
        'chapter': level.chapter,
        'rows': level.rows,
        'cols': level.cols,
        'par': level.par,
        'emptyCells': level.emptyCells,
        'paths': level.paths.map((path) {
          return {
            'id': path.id,
            'colorIndex': path.colorIndex,
            'segments': path.segments.map((seg) {
              return {'row': seg.row, 'col': seg.col};
            }).toList(),
          };
        }).toList(),
      };
    }).toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);
    final file = File('assets/levels/chapter_$chapterNum.json');
    file.writeAsStringSync(jsonStr);
    
    print('Chapter $chapterNum: ${levels.length} levels → ${file.path} (${jsonStr.length} bytes)');
  }

  print('\n✅ All chapters exported successfully!');
}
