import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사운드, 진동, 테마 등 앱 환경설정을 관리하는 싱글톤
class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;

  // 기본 설정 상태
  bool _sfxEnabled = true;
  bool _bgmEnabled = true;
  bool _hapticEnabled = true;
  bool _showGrid = true;
  String _languageCode = 'en';

  // Getters
  bool get sfxEnabled => _sfxEnabled;
  bool get bgmEnabled => _bgmEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get showGrid => _showGrid;
  String get languageCode => _languageCode;

  /// 앱 구동 시 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    _sfxEnabled = _prefs.getBool('setting_sfx') ?? true;
    _bgmEnabled = _prefs.getBool('setting_bgm') ?? true;
    _hapticEnabled = _prefs.getBool('setting_haptic') ?? true;
    _showGrid = _prefs.getBool('setting_show_grid') ?? true;
    _languageCode = _prefs.getString('setting_language') ?? 'en';
  }

  // Setters (값 변경 후 즉시 저장 및 리스너 알림)
  void setSfxEnabled(bool value) {
    if (_sfxEnabled == value) return;
    _sfxEnabled = value;
    _prefs.setBool('setting_sfx', value);
    notifyListeners();
  }

  void setBgmEnabled(bool value) {
    if (_bgmEnabled == value) return;
    _bgmEnabled = value;
    _prefs.setBool('setting_bgm', value);
    notifyListeners();
  }

  void setHapticEnabled(bool value) {
    if (_hapticEnabled == value) return;
    _hapticEnabled = value;
    _prefs.setBool('setting_haptic', value);
    notifyListeners();
  }

  void setShowGrid(bool value) {
    if (_showGrid == value) return;
    _showGrid = value;
    _prefs.setBool('setting_show_grid', value);
    notifyListeners();
  }

  void setLanguageCode(String code) {
    if (_languageCode == code) return;
    _languageCode = code;
    _prefs.setString('setting_language', code);
    notifyListeners();
  }
}
