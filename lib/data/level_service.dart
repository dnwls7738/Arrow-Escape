import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/logger.dart';
import '../models/level_data.dart';

/// JSON 에셋 / 로컬 캐시 / Firestore에서 레벨 데이터를 로딩 및 동기화하는 서비스
class LevelService extends ChangeNotifier {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  static const int _totalChapters = 5;
  static const String _versionKey = 'local_levels_version';

  List<List<LevelData>> _chapters = [];
  bool _isLoaded = false;
  int _currentVersion = 1;

  List<List<LevelData>> get chapters => _chapters;
  bool get isLoaded => _isLoaded;
  List<LevelData> get allLevels => _chapters.expand((c) => c).toList();

  /// 앱 시작 시 호출 — 캐시/에셋 로드 후 무결성 확인 및 백그라운드 OTA 업데이트
  Future<void> init() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentVersion = prefs.getInt(_versionKey) ?? 1;

      // 1. 로컬 캐시(path_provider)에서 시도
      bool loadedFromCache = await _tryLoadFromCache();

      // 2. 실패 시 번들 에셋에서 로드 (기본 버전 1 상태)
      if (!loadedFromCache) {
        _chapters = await _loadFromAssets();
        _currentVersion = 1;
        await prefs.setInt(_versionKey, 1);
      }
      
      _isLoaded = true;
      Logger.log('ℹ️ Loaded ${allLevels.length} levels (Version: $_currentVersion)');
      notifyListeners();

      // 3. 백그라운드 캐시 무효화 및 새 버전 확인
      _checkForUpdates();
    } catch (e) {
      Logger.log('❌ Failed to init LevelService: $e');
      _chapters = List.generate(_totalChapters, (_) => <LevelData>[]);
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// 로컬 앱 데이터 디렉토리에서 앞서 받아둔 JSON 로딩
  Future<bool> _tryLoadFromCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final List<List<LevelData>> cachedChapters = [];

      for (int i = 1; i <= _totalChapters; i++) {
        final file = File('${dir.path}/levels/chapter_$i.json');
        if (!await file.exists()) {
          return false; // 하나라도 캐시가 비어있으면 전체 폴백
        }
        final jsonStr = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        final levels = jsonList.map((item) => _mapToLevelData(Map<String, dynamic>.from(item)))
            .whereType<LevelData>().toList();
        cachedChapters.add(levels);
      }
      
      _chapters = cachedChapters;
      return true;
    } catch (e) {
      Logger.log('⚠️ Cache load failed, falling back to assets: $e');
      return false;
    }
  }

  /// 앱에 내장된 기본 assets 로딩
  Future<List<List<LevelData>>> _loadFromAssets() async {
    final List<List<LevelData>> chapters = [];
    for (int i = 1; i <= _totalChapters; i++) {
      final jsonStr = await rootBundle.loadString('assets/levels/chapter_$i.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final levels = jsonList.map((item) => _mapToLevelData(Map<String, dynamic>.from(item)))
          .whereType<LevelData>().toList();
      chapters.add(levels);
    }
    return chapters;
  }

  /// Firestore에서 metadata/levels 버전 확인 후 새 버전이면 다운로드
  Future<void> _checkForUpdates() async {
    try {
      final db = FirebaseFirestore.instance;
      // 오프라인 상태일 때 오래 대기하지 않고 빠른 실패 유도
      final metadataDoc = await db.collection('metadata').doc('levels').get(
        const GetOptions(source: Source.server)
      ).timeout(const Duration(seconds: 5));
      
      if (!metadataDoc.exists || metadataDoc.data() == null) return;
      
      final cloudVersion = metadataDoc.data()!['version'] as int? ?? 1;
      
      if (cloudVersion > _currentVersion) {
        Logger.log('🔄 New levels OTA version found: $cloudVersion (Local: $_currentVersion)');
        await _downloadAndCacheLevels(db, cloudVersion);
      }
    } catch (e) {
      Logger.log('⚠️ Background update check failed (offline?): $e');
    }
  }

  /// Firestore 'levels' 컬렉션에 보관된 모든 레벨 문서를 받아 캐싱
  /// 문서 1MB 제약을 피하기 위해 컬렉션에서 여러 문서를 쿼리하여 재결합
  Future<void> _downloadAndCacheLevels(FirebaseFirestore db, int newVersion) async {
    try {
      final snapshot = await db.collection('levels').get();
      if (snapshot.docs.isEmpty) throw Exception('No levels found in Firestore');

      final List<LevelData> newLevels = snapshot.docs
          .map((doc) => _mapToLevelData(doc.data()))
          .whereType<LevelData>()
          .toList();

      // 챕터별로 재분류 (최대 챕터 동적 파악)
      final int maxChapter = newLevels.fold(0, (max, level) => level.chapter > max ? level.chapter : max);
      final int targetChapters = maxChapter > _totalChapters ? maxChapter : _totalChapters;

      final List<List<LevelData>> groupedChapters = List.generate(targetChapters, (_) => <LevelData>[]);
      for (var level in newLevels) {
        if (level.chapter > 0 && level.chapter <= targetChapters) {
          groupedChapters[level.chapter - 1].add(level);
        }
      }

      // 각 챕터 내부 Level ID로 정렬
      for (var chapter in groupedChapters) {
        chapter.sort((a, b) => a.id.compareTo(b.id));
      }

      // 캐시 폴더 안 JSON 형태로 쓰기
      final dir = await getApplicationDocumentsDirectory();
      final levelsDir = Directory('${dir.path}/levels');
      if (!await levelsDir.exists()) {
        await levelsDir.create(recursive: true);
      }

      for (int i = 0; i < targetChapters; i++) {
        final chapterNum = i + 1;
        final jsonList = groupedChapters[i].map((l) => _mapToJsonData(l)).toList();
        final jsonStr = jsonEncode(jsonList);
        
        final file = File('${levelsDir.path}/chapter_$chapterNum.json');
        await file.writeAsString(jsonStr);
      }

      // 메모리 업데이트 및 버전 갱신
      _chapters = groupedChapters;
      _currentVersion = newVersion;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_versionKey, newVersion);
      
      notifyListeners();
      Logger.log('✅ Successfully downloaded OTA levels (v$newVersion) from Firestore.');
    } catch (e) {
      Logger.log('❌ Failed to download OTA levels: $e');
    }
  }

  /// Map → LevelData
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

  /// LevelData → json 상호 변환용 (캐시 저장 용도)
  Map<String, dynamic> _mapToJsonData(LevelData level) {
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
  }
}
