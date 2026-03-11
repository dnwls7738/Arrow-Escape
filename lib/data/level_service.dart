import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/logger.dart';
import '../models/level_data.dart';

/// JSON 에셋에서 레벨 데이터를 로딩하는 싱글톤 서비스
class LevelService extends ChangeNotifier {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  static const int _totalChapters = 5;

  List<List<LevelData>> _chapters = [];
  bool _isLoaded = false;

  List<List<LevelData>> get chapters => _chapters;
  bool get isLoaded => _isLoaded;
  List<LevelData> get allLevels => _chapters.expand((c) => c).toList();

  /// 앱 시작 시 호출 — JSON 에셋에서 레벨 데이터 로딩
  Future<void> init() async {
    if (_isLoaded) return;

    try {
      _chapters = await _loadFromAssets();
      _isLoaded = true;
      Logger.log('ℹ️ Loaded ${allLevels.length} levels from JSON assets');
    } catch (e) {
      Logger.log('❌ Failed to load levels from assets: $e');
      _chapters = List.generate(_totalChapters, (_) => <LevelData>[]);
      _isLoaded = true;
    }
    notifyListeners();
  }

  /// assets/levels/chapter_N.json 파일들에서 레벨 로딩
  Future<List<List<LevelData>>> _loadFromAssets() async {
    final List<List<LevelData>> chapters = [];

    for (int i = 1; i <= _totalChapters; i++) {
      final jsonStr = await rootBundle.loadString('assets/levels/chapter_$i.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);

      final levels = jsonList.map((item) {
        return _mapToLevelData(Map<String, dynamic>.from(item));
      }).whereType<LevelData>().toList();

      chapters.add(levels);
    }

    return chapters;
  }

  /// Map → LevelData 변환
  LevelData? _mapToLevelData(Map<String, dynamic> data) {
    try {
      final paths = (data['paths'] as List).map((p) {
        final pMap = Map<String, dynamic>.from(p);
        final segments = (pMap['segments'] as List).map((s) {
          final sMap = Map<String, dynamic>.from(s);
          return Coordinate(row: sMap['row'] as int, col: sMap['col'] as int);
        }).toList();

        return PathData(
          id: pMap['id'] as int,
          colorIndex: pMap['colorIndex'] as int,
          segments: segments,
        );
      }).toList();

      return LevelData(
        id: data['id'] as int,
        chapter: data['chapter'] as int,
        rows: data['rows'] as int,
        cols: data['cols'] as int,
        paths: paths,
        par: data['par'] as int,
        emptyCells: data['emptyCells'] != null
            ? List<String>.from(data['emptyCells'])
            : const [],
      );
    } catch (e) {
      Logger.log('Error parsing level ${data['id']}: $e');
      return null;
    }
  }
}
