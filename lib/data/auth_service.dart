import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 인증 서비스 — 추후 Apple Sign-In 추가가 쉽도록 추상화
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 현재 로그인한 유저 (없으면 null)
  User? get currentUser => _auth.currentUser;

  /// 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 로그인 여부
  bool get isLoggedIn => _auth.currentUser != null;

  /// 구글 로그인 (익명 계정이면 연결, 아니면 새 로그인)
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return '로그인이 취소되었습니다.';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 현재 익명 계정이면 → 구글 계정으로 연결 (UID 유지!)
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        try {
          return await currentUser.linkWithCredential(credential);
        } catch (e) {
          // 이미 연결된 계정이면 일반 로그인으로 폴백
          Logger.log('Link failed, falling back to signIn: $e');
          return await _auth.signInWithCredential(credential);
        }
      }

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      Logger.log('Google Sign-In Error: $e');
      if (e is FirebaseAuthException) {
        return 'Firebase 오류: ${e.message}';
      }
      return '구글 로그인 실패: $e';
    }
  }

  /// 익명 로그인 (게스트 모드)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      Logger.log('Anonymous Sign-In Error: $e');
      return null;
    }
  }

  /// 로그아웃 후 자동 익명 재로그인
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await signInAnonymously();
  }

  /// 구글 재인증 (계정 삭제 전 필수)
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      Logger.log('Reauthentication error: $e');
      return false;
    }
  }

  /// 계정 완전 삭제 (Firebase Auth)
  Future<String?> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return '로그인 상태가 아닙니다.';

      await user.delete();
      await _googleSignIn.signOut();
      // 삭제 후 게스트로 전환
      await signInAnonymously();
      return null; // 성공
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'REAUTH_REQUIRED';
      }
      return '계정 삭제 실패: ${e.message}';
    } catch (e) {
      return '계정 삭제 실패: $e';
    }
  }
}
