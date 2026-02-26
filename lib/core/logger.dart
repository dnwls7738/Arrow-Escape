import 'package:flutter/foundation.dart';

/// 앱 전역에서 사용할 로거 클래스
/// 릴리스 빌드(Release Build) 시에는 kDebugMode가 false가 되어, 
/// 로그 출력을 방지하여 성능을 최적화하고 불필요한 정보 노출을 막습니다.
class Logger {
  /// 일반 로그 (개발/디버깅용)
  static void log(String message) {
    if (kDebugMode) {
      print('[ArrowEscape] $message');
    }
  }

  /// 에러 로그 (개발/디버깅용)
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [ArrowEscape ERROR] $message');
      if (error != null) {
        print('Exception: $error');
      }
      if (stackTrace != null) {
        print('StackTrace:\n$stackTrace');
      }
    }
  }
}
