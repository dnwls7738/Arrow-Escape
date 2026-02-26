import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Guest 계정 및 향후 로그인 동기화를 관리하는 클래스
class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  late SharedPreferences _prefs;
  String _guestId = '';

  String get guestId => _guestId;

  /// 앱 구동 시 가장 먼저 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // 기존 설정된 Guest ID 확인
    final savedId = _prefs.getString('guest_id');
    if (savedId != null && savedId.isNotEmpty) {
      _guestId = savedId;
    } else {
      // 없다면 새로운 난수(Guest ID) 발급 후 저장
      _guestId = 'guest_${const Uuid().v4()}';
      await _prefs.setString('guest_id', _guestId);
    }
  }

  // TODO(Phase 2): 구글/애플 로그인 기능 및 클라우드 동기화(Merge) 메서드 추가 예정
}
