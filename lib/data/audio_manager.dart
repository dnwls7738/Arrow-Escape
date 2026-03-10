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

  /// 앱 구동 시 오디오 캐시 로드
  Future<void> init() async {
    if (_initialized) return;
    try {
      // 에뮬레이터에서 오디오 캐싱(loadAll) 시 JVM이 터지는 현상을 방지하기 위해
      // 여기서 미리 로드하지 않고, 첫 재생 시점(FlameAudio.play)에서 
      // 지연 로딩되도록 변경합니다. (Lazy Loading)
      _initialized = true;
    } catch (e) {
      Logger.log('AudioManager init warning: $e');
    }
  }

  // ── SFX ──

  void playShoot() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    FlameAudio.play('shoot.ogg', volume: 0.3);
  }

  void playBlocked() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    FlameAudio.play('blocked.ogg', volume: 0.3);
  }

  void playClear() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    FlameAudio.play('clear.ogg', volume: 0.3);
  }

  void playClick() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    FlameAudio.play('click.ogg', volume: 0.3);
  }

  void playUndo() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
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
