import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/logger.dart';
import '../core/constants.dart';
import '../models/level_data.dart';
import 'levels.dart' as local;

/// Firestore에서 레벨 데이터를 동적으로 로딩하는 싱글톤 서비스
/// 로딩 순서: ① 로컬 캐시 → ② Firestore(백그라운드 갱신) → ③ levels.dart 폴백
class LevelService extends ChangeNotifier {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  static const _cacheKey = 'cached_levels_json';
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<List<LevelData>> _chapters = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  List<List<LevelData>> get chapters => _chapters;
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  List<LevelData> get allLevels => _chapters.expand((c) => c).toList();

  /// 앱 시작 시 호출
  Future<void> init() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;
    notifyListeners();

    // TEMP: 로컬 levels.dart의 새 데이터를 강제로 불러오기 위해 캐시 및 Firestore 비활성화
    // TODO: 프로덕션에서는 버전 관리를 통해 캐시 무효화를 구현해야 함
    _loadFromLocal();
    _isLoaded = true;
    _isLoading = false;
    Logger.log('ℹ️ Levels FORCED loaded from local fallback (new 15x15 data)');
    notifyListeners();
  }

  /// 캐시에서 레벨 로드
  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr == null) return false;

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final List<LevelData> levels = [];
      for (final item in jsonList) {
        final level = _mapToLevelData(Map<String, dynamic>.from(item));
        if (level != null) levels.add(level);
      }

      if (levels.isEmpty) return false;
      _chapters = _groupByChapter(levels);
      return true;
    } catch (e) {
      Logger.log('Cache load error: $e');
      return false;
    }
  }

  /// Firestore → 캐시에 저장
  Future<void> _saveToCache(List<Map<String, dynamic>> rawLevels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(rawLevels));
    } catch (e) {
      Logger.log('Cache save error: $e');
    }
  }

  /// 백그라운드에서 Firestore 갱신 (UI 블로킹 없음)
  Future<void> _refreshFromFirestore() async {
    try {
      final snapshot = await _db.collection('levels').get()
          .timeout(const Duration(seconds: 15));
      
      if (snapshot.docs.isEmpty) return;

      final List<Map<String, dynamic>> rawLevels = [];
      final List<LevelData> levels = [];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        rawLevels.add(data);
        final level = _mapToLevelData(data);
        if (level != null) levels.add(level);
      }

      if (levels.isNotEmpty && levels.length != allLevels.length) {
        // 새 레벨이 추가된 경우에만 UI 갱신
        _chapters = _groupByChapter(levels);
        Logger.log('🔄 Levels refreshed from Firestore (${levels.length} levels)');
        notifyListeners();
      }

      // 캐시 갱신
      await _saveToCache(rawLevels);
    } catch (e) {
      Logger.log('Background refresh failed: $e');
    }
  }

  /// Firestore에서 레벨 로딩
  Future<bool> _loadFromFirestore() async {
    final snapshot = await _db.collection('levels').get();
    if (snapshot.docs.isEmpty) return false;

    final List<Map<String, dynamic>> rawLevels = [];
    final List<LevelData> levels = [];
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      rawLevels.add(data);
      final level = _mapToLevelData(data);
      if (level != null) levels.add(level);
    }

    if (levels.isEmpty) return false;

    _chapters = _groupByChapter(levels);
    // 캐시에 저장
    await _saveToCache(rawLevels);
    return true;
  }

  /// 로컬 levels.dart에서 로딩 (최종 폴백)
  void _loadFromLocal() {
    _chapters = [
      local.chapter1Levels,
      local.chapter2Levels,
      local.chapter3Levels,
      local.chapter4Levels,
      local.chapter5Levels,
    ];
  }

  /// Map → LevelData 변환
  LevelData? _mapToLevelData(Map<String, dynamic> data) {
    try {
      final arrows = (data['arrows'] as List).map((a) {
        final aMap = Map<String, dynamic>.from(a);
        return ArrowData(
          row: aMap['row'] as int,
          col: aMap['col'] as int,
          direction: _parseDirection(aMap['direction'] as String),
        );
      }).toList();

      return LevelData(
        id: data['id'] as int,
        chapter: data['chapter'] as int,
        rows: data['rows'] as int,
        cols: data['cols'] as int,
        arrows: arrows,
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

  ArrowDirection _parseDirection(String dir) {
    switch (dir) {
      case 'up': return ArrowDirection.up;
      case 'down': return ArrowDirection.down;
      case 'left': return ArrowDirection.left;
      case 'right': return ArrowDirection.right;
      default: return ArrowDirection.up;
    }
  }

  List<List<LevelData>> _groupByChapter(List<LevelData> levels) {
    final Map<int, List<LevelData>> grouped = {};
    for (final level in levels) {
      grouped.putIfAbsent(level.chapter, () => []);
      grouped[level.chapter]!.add(level);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    // 각 챕터 내에서 레벨 ID 순으로 정렬
    for (final key in sortedKeys) {
      grouped[key]!.sort((a, b) => a.id.compareTo(b.id));
    }
    return sortedKeys.map((k) => grouped[k]!).toList();
  }
}
