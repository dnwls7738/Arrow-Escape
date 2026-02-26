import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cloud_save_service.dart';

/// 레벨별 별점을 기기 로컬에 영구 저장 및 관리하는 싱글톤
class ScoreManager extends ChangeNotifier {
  static final ScoreManager _instance = ScoreManager._internal();
  factory ScoreManager() => _instance;
  ScoreManager._internal();

  late SharedPreferences _prefs;
  final Map<int, int> _stars = {};

  int _sessionClearCount = 0;

  /// 앱 구동 시 가장 먼저 저장소에서 데이터를 로드
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    _stars.clear();
    final prefix = 'level_stars_';
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final levelIdStr = key.replaceFirst(prefix, '');
        final levelId = int.tryParse(levelIdStr);
        if (levelId != null) {
          _stars[levelId] = _prefs.getInt(key) ?? 0;
        }
      }
    }
    notifyListeners();
  }

  /// 클라우드 백업용 전체 별점 데이터 추출
  Map<String, dynamic> getAllStars() {
    final Map<String, dynamic> map = {};
    _stars.forEach((key, value) {
      map[key.toString()] = value;
    });
    return map;
  }

  /// 클라우드 다운로드 시 데이터 병합 (더 높은 별점 반영)
  Future<void> mergeStars(Map<String, dynamic> cloudStars) async {
    bool changed = false;
    for (final entry in cloudStars.entries) {
      final levelId = int.tryParse(entry.key);
      if (levelId != null) {
        final cloudScore = (entry.value as int?) ?? 0;
        final localScore = _stars[levelId] ?? 0;
        
        if (cloudScore > localScore) {
          _stars[levelId] = cloudScore;
          await _prefs.setInt('level_stars_$levelId', cloudScore);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  /// 해당 레벨의 별점 조회
  int getStars(int levelId) => _stars[levelId] ?? 0;

  /// 현재 세션(앱 실행 후)의 레벨 클리어 횟수
  int get sessionClearCount => _sessionClearCount;

  /// 레벨 클리어 완료 호출 (별점 로컬 저장 + 클라우드 즉시 백업)
  void recordLevelClear(int levelId, int stars) {
    _sessionClearCount++;
    
    final current = _stars[levelId] ?? 0;
    if (stars > current) {
      _stars[levelId] = stars;
      _prefs.setInt('level_stars_$levelId', stars);
      notifyListeners();
      
      // 클라우드 동기화 
      CloudSaveService().syncLevelClear(levelId, stars);
    }
  }

  /// 세션 클리어 횟수 초기화 (주로 전면 광고 시청 후 호출)
  void resetSessionClearCount() {
    _sessionClearCount = 0;
  }

  /// 진행 상황 초기화 (Settings 메뉴용)
  Future<void> resetAll() async {
    _stars.clear();
    
    final prefix = 'level_stars_';
    final keys = _prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
    
    notifyListeners();
  }
}
