import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import '../core/logger.dart';
import 'settings_manager.dart';

/// 게임 내 SFX + BGM 오디오를 관리하는 싱글톤
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _bgmPlaying = false;

  /// 앱 구동 시 오디오 캐시 초기화
  Future<void> init() async {
    if (_initialized) return;
    try {
      // SFX 프리로드
      await FlameAudio.audioCache.loadAll([
        'shoot.ogg',
        'blocked.ogg',
        'clear.ogg',
        'click.ogg',
        'undo.ogg',
      ]);
      _initialized = true;
    } catch (e) {
      // 오디오 초기화 실패 시 무시 (웹 환경 첫 로드 등)
      Logger.log('AudioManager init warning: $e');
    }
  }

  // ── SFX ──

  void playShoot() {
    if (!SettingsManager().sfxEnabled) return;
    FlameAudio.play('shoot.ogg', volume: 0.3);
  }

  void playBlocked() {
    if (!SettingsManager().sfxEnabled) return;
    FlameAudio.play('blocked.ogg', volume: 0.3);
  }

  void playClear() {
    if (!SettingsManager().sfxEnabled) return;
    FlameAudio.play('clear.ogg', volume: 0.3);
  }

  void playClick() {
    if (!SettingsManager().sfxEnabled) return;
    FlameAudio.play('click.ogg', volume: 0.3);
  }

  void playUndo() {
    if (!SettingsManager().sfxEnabled) return;
    FlameAudio.play('undo.ogg', volume: 0.3);
  }

  // ── BGM ──

  void startBgm() {
    if (!SettingsManager().bgmEnabled) return;
    if (_bgmPlaying) return;
    try {
      FlameAudio.bgm.play('bgm.wav', volume: 1);
      _bgmPlaying = true;
    } catch (e) {
      Logger.log('BGM play warning: $e');
    }
  }

  void stopBgm() {
    if (!_bgmPlaying) return;
    FlameAudio.bgm.stop();
    _bgmPlaying = false;
  }

  /// 설정이 변경될 때 호출
  void onSettingsChanged() {
    if (SettingsManager().bgmEnabled && !_bgmPlaying) {
      startBgm();
    } else if (!SettingsManager().bgmEnabled && _bgmPlaying) {
      stopBgm();
    }
  }
}
