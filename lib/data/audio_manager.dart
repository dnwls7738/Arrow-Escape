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

  late AudioPool _shootPool;
  late AudioPool _blockedPool;
  late AudioPool _clearPool;
  late AudioPool _clickPool;
  late AudioPool _undoPool;

  /// 앱 구동 시 오디오 캐시 및 풀 초기화
  Future<void> init() async {
    if (_initialized) return;
    try {
      // SFX 프리로드 및 AudioPool 생성
      _shootPool = await FlameAudio.createPool('shoot.ogg', minPlayers: 1, maxPlayers: 15);
      _blockedPool = await FlameAudio.createPool('blocked.ogg', minPlayers: 1, maxPlayers: 5);
      _clearPool = await FlameAudio.createPool('clear.ogg', minPlayers: 1, maxPlayers: 2);
      _clickPool = await FlameAudio.createPool('click.ogg', minPlayers: 1, maxPlayers: 5);
      _undoPool = await FlameAudio.createPool('undo.ogg', minPlayers: 1, maxPlayers: 5);

      _initialized = true;
    } catch (e) {
      // 오디오 초기화 실패 시 무시 (웹 환경 첫 로드 등)
      Logger.log('AudioManager init warning: $e');
    }
  }

  // ── SFX ──

  void playShoot() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    _shootPool.start(volume: 0.3);
  }

  void playBlocked() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    _blockedPool.start(volume: 0.3);
  }

  void playClear() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    _clearPool.start(volume: 0.3);
  }

  void playClick() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    _clickPool.start(volume: 0.3);
  }

  void playUndo() {
    if (!SettingsManager().sfxEnabled || !_initialized) return;
    _undoPool.start(volume: 0.3);
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
