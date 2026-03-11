import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'settings_manager.dart';
import 'score_manager.dart';
import 'level_service.dart';
import 'audio_manager.dart';
import 'haptic_manager.dart';
import 'ad_manager.dart';
import 'user_manager.dart';

/// SettingsManager — ChangeNotifier이므로 ChangeNotifierProvider 사용
final settingsProvider = ChangeNotifierProvider<SettingsManager>((ref) {
  return SettingsManager();
});

/// ScoreManager — ChangeNotifier이므로 ChangeNotifierProvider 사용
final scoreProvider = ChangeNotifierProvider<ScoreManager>((ref) {
  return ScoreManager();
});

/// LevelService — ChangeNotifier이므로 ChangeNotifierProvider 사용
final levelServiceProvider = ChangeNotifierProvider<LevelService>((ref) {
  return LevelService();
});

/// AudioManager — 일반 싱글톤 (Provider로 노출)
final audioProvider = Provider<AudioManager>((ref) {
  return AudioManager();
});

/// HapticManager — 일반 싱글톤 (Provider로 노출)
final hapticProvider = Provider<HapticManager>((ref) {
  return HapticManager();
});

/// AdManager — 일반 싱글톤 (Provider로 노출)
final adProvider = Provider<AdManager>((ref) {
  return AdManager();
});

/// UserManager — 일반 싱글톤 (Provider로 노출)
final userProvider = Provider<UserManager>((ref) {
  return UserManager();
});
