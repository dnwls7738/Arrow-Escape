import 'package:flutter/foundation.dart';
import '../core/logger.dart';
import '../models/level_data.dart';
import 'levels.dart' as local;

/// 레벨 데이터를 로딩하는 싱글톤 서비스
/// 현재는 로컬 levels.dart에서 직접 로딩
class LevelService extends ChangeNotifier {
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  List<List<LevelData>> _chapters = [];
  bool _isLoaded = false;

  List<List<LevelData>> get chapters => _chapters;
  bool get isLoaded => _isLoaded;
  List<LevelData> get allLevels => _chapters.expand((c) => c).toList();

  /// 앱 시작 시 호출
  Future<void> init() async {
    if (_isLoaded) return;

    _loadFromLocal();
    _isLoaded = true;
    Logger.log('ℹ️ Levels loaded from local data');
    notifyListeners();
  }

  /// 로컬 levels.dart에서 로딩
  void _loadFromLocal() {
    _chapters = [
      local.chapter1Levels,
      local.chapter2Levels,
      local.chapter3Levels,
      local.chapter4Levels,
      local.chapter5Levels,
    ];
  }
}
