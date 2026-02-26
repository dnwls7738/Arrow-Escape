import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'score_manager.dart';

/// 클라우드 진행도 동기화 서비스
/// 로컬(ScoreManager) ↔ Firestore 양방향 동기화
class CloudSaveService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Firestore에 진행도 업로드
  Future<void> uploadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final prefs = await SharedPreferences.getInstance();
    
    // 로컬 진행도 수집
    final Map<String, dynamic> data = {
      'levelStars': ScoreManager().getAllStars(),
      'totalHintsUsed': prefs.getInt('totalHintsUsed') ?? 0,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _db
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  /// Firestore에서 진행도 다운로드 → 로컬에 병합 저장
  Future<void> downloadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data()!;
      final prefs = await SharedPreferences.getInstance();

      // 별점 복원 및 로컬과 병합
      if (data['levelStars'] != null) {
        final Map<String, dynamic> stars = Map<String, dynamic>.from(data['levelStars']);
        await ScoreManager().mergeStars(stars);
      }

      // 힌트 사용 횟수 동기화
      if (data['totalHintsUsed'] != null) {
        final localHints = prefs.getInt('totalHintsUsed') ?? 0;
        final cloudHints = data['totalHintsUsed'] as int;
        if (cloudHints > localHints) {
          await prefs.setInt('totalHintsUsed', cloudHints);
        }
      }
    } catch (e) {
      Logger.log('Cloud download error: $e');
    }
  }

  /// 레벨 클리어 시 클라우드 부분 업데이트
  Future<void> syncLevelClear(int levelId, int stars) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _db.collection('users').doc(user.uid).set({
        'levelStars': {levelId.toString(): stars},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      Logger.log('Sync error: $e');
      // 오프라인이면 무시 — 나중에 일괄 동기화 가능
    }
  }

  /// Firestore에서 유저 데이터 소프트 삭제
  /// users → deleted_users로 이동 (30일 보관 후 완전 삭제)
  Future<void> deleteUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 원본 데이터 읽기
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        // deleted_users로 복사 + 삭제 시간 기록
        await _db.collection('deleted_users').doc(user.uid).set({
          ...doc.data()!,
          'deletedAt': FieldValue.serverTimestamp(),
          'scheduledPurgeAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        });
      }
      
      // 원본 삭제
      await _db.collection('users').doc(user.uid).delete();
      Logger.log('🗑️ User data soft-deleted: ${user.uid}');
    } catch (e) {
      Logger.log('Delete user data error: $e');
    }
  }

  /// 로그인 직후 삭제된 계정이 있는지 확인하고, 있으면 자동 복구
  /// (구글 연동 해제 후 재로그인 시 UID가 변경될 수 있으므로 email로 탐색)
  Future<bool> checkAndRestoreUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous || user.email == null || user.email!.isEmpty) return false;

    try {
      final querySnapshot = await _db
          .collection('deleted_users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 복구: 가장 최근에 삭제된 데이터를 찾아 현재 UID의 users 컬렉션으로 복구
        final deletedDoc = querySnapshot.docs.first;
        
        await _db.collection('users').doc(user.uid).set({
          ...deletedDoc.data(),
          'restoredAt': FieldValue.serverTimestamp(),
          // 필요 없는 기존 삭제 관련 필드는 덮어쓰거나 지울 수 있지만 여기선 그대로 둡니다
        });
        
        // 원본(deleted_users) 문서 삭제
        await _db.collection('deleted_users').doc(deletedDoc.id).delete();
        Logger.log('♻️ User data restored for: ${user.email} (new uid: ${user.uid})');
        return true;
      }
    } catch (e) {
      Logger.log('Restore user data error: $e');
    }
    return false;
  }
}
