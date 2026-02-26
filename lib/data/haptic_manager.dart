import 'package:flutter/services.dart';
import 'settings_manager.dart';

/// 햅틱 피드백(진동)을 관리하는 싱글톤
class HapticManager {
  static final HapticManager _instance = HapticManager._internal();
  factory HapticManager() => _instance;
  HapticManager._internal();

  /// 가벼운 피드백 (UI 버튼 탭)
  void light() {
    if (!SettingsManager().hapticEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// 중간 피드백 (화살표 발사 성공)
  void medium() {
    if (!SettingsManager().hapticEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// 강한 피드백 (차단/에러)
  void heavy() {
    if (!SettingsManager().hapticEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// 성공 피드백 (레벨 클리어)
  void success() {
    if (!SettingsManager().hapticEnabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
  }
}
