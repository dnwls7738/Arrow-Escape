/// Firestore에 기존 75개 레벨을 업로드하는 1회성 스크립트
/// 사용법: dart run bin/upload_levels.dart
///
/// 주의: Firebase Admin SDK가 아닌 REST API로 직접 업로드합니다.
/// 또는 앱 내에서 한 번 실행할 수도 있습니다.

import 'dart:convert';
import 'dart:io';

// levels.dart에서 레벨 데이터를 읽어 JSON으로 변환 후 파일로 저장
// 이 JSON을 Firebase 콘솔이나 관리자 페이지에서 import 합니다

void main() {
  // levels.dart 파일을 파싱하여 JSON으로 변환
  final levelsFile = File('lib/data/levels.dart');
  final content = levelsFile.readAsStringSync();
  
  // 정규식으로 레벨 데이터 추출
  final levelPattern = RegExp(
    r'const LevelData\(\s*'
    r'id:\s*(\d+),\s*chapter:\s*(\d+),\s*rows:\s*(\d+),\s*cols:\s*(\d+),\s*'
    r'arrows:\s*\[(.*?)\],\s*'
    r'par:\s*(\d+)',
    dotAll: true,
  );
  
  final arrowPattern = RegExp(
    r'ArrowData\(row:\s*(\d+),\s*col:\s*(\d+),\s*direction:\s*ArrowDirection\.(\w+)\)',
  );
  
  List<Map<String, dynamic>> levels = [];
  
  for (final match in levelPattern.allMatches(content)) {
    final id = int.parse(match.group(1)!);
    final chapter = int.parse(match.group(2)!);
    final rows = int.parse(match.group(3)!);
    final cols = int.parse(match.group(4)!);
    final arrowsStr = match.group(5)!;
    final par = int.parse(match.group(6)!);
    
    List<Map<String, dynamic>> arrows = [];
    for (final am in arrowPattern.allMatches(arrowsStr)) {
      arrows.add({
        'row': int.parse(am.group(1)!),
        'col': int.parse(am.group(2)!),
        'direction': am.group(3)!,
      });
    }
    
    levels.add({
      'id': id,
      'chapter': chapter,
      'rows': rows,
      'cols': cols,
      'arrows': arrows,
      'par': par,
      'emptyCells': [],
    });
  }
  
  // JSON 파일로 저장
  final jsonFile = File('levels_export.json');
  final encoder = JsonEncoder.withIndent('  ');
  jsonFile.writeAsStringSync(encoder.convert(levels));
  
  print('✅ ${levels.length}개 레벨을 levels_export.json에 저장했습니다.');
  print('   이 파일을 관리자 페이지에서 Firestore에 import할 수 있습니다.');
  
  // 챕터별 요약
  Map<int, int> chapterCount = {};
  for (final l in levels) {
    chapterCount[l['chapter'] as int] = (chapterCount[l['chapter'] as int] ?? 0) + 1;
  }
  chapterCount.forEach((ch, count) {
    print('   Chapter $ch: $count levels');
  });
}
