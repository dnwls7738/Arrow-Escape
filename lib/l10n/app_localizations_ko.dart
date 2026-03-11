// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'ARROW ESCAPE';

  @override
  String get menuPlay => '게임 시작';

  @override
  String get menuSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsGameDisplay => '게임 및 디스플레이';

  @override
  String get settingsAccountData => '계정 및 데이터';

  @override
  String get settingsHaptic => '진동 피드백';

  @override
  String get settingsSfx => '효과음 (SFX)';

  @override
  String get settingsBgm => '배경음악 (BGM)';

  @override
  String get settingsDots => '배경 도트 표시';

  @override
  String get settingsLanguage => '언어 (Language)';

  @override
  String get playingAsGuest => '게스트로 플레이 중';

  @override
  String get guestDescription => '진행 상황이 기기에 저장됩니다.\n로그인하면 클라우드에 동기화할 수 있어요!';

  @override
  String get signInGoogle => 'Google로 로그인';

  @override
  String get signingIn => '로그인 중...';

  @override
  String get signInSuccess => '로그인 성공! 동기화 중...';

  @override
  String get accountRestored => '다시 오신 것을 환영합니다! 삭제된 계정이 복구되었습니다. ♻️';

  @override
  String get progressSynced => '진행 상황 동기화 완료! ✅';

  @override
  String get signInApple => 'Apple로 로그인';

  @override
  String get appleSignInSoon => 'Apple 로그인은 곧 지원됩니다!';

  @override
  String get googleAccount => 'Google 계정';

  @override
  String get connected => '연결됨';

  @override
  String get forceUpdateCloud => '클라우드에서 강제 업데이트';

  @override
  String get downloadingProgress => '진행 상황 다운로드 중...';

  @override
  String get downloadComplete => '다운로드 완료!';

  @override
  String get signOut => '로그아웃';

  @override
  String get signedOut => '로그아웃 되었습니다.';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get resetAllProgress => '모든 진행 초기화';

  @override
  String get resetProgressTitle => '진행 초기화';

  @override
  String get resetProgressMsg => '모든 레벨 기록과 별을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get allProgressReset => '모든 진행 상황이 초기화되었습니다.';

  @override
  String get deleteAccountTitle => '계정 삭제';

  @override
  String get deleteAccountMsg =>
      '다음 항목이 영구적으로 삭제됩니다:\n• Google 계정 연동\n• 모든 클라우드 저장 데이터\n• 모든 로컬 데이터\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteAccountBtn => '계정 삭제';

  @override
  String get deletingAccount => '계정 삭제 중...';

  @override
  String get reauthPrompt => '삭제를 확인하려면 다시 로그인해 주세요.';

  @override
  String get reauthCancelled => '재인증이 취소되었습니다.';

  @override
  String get accountDeleted => '계정이 삭제되었습니다. 게스트로 플레이합니다.';

  @override
  String get levelSelectTitle => '레벨 선택';

  @override
  String chapterName(int chapterIndex) {
    return '챕터 $chapterIndex';
  }

  @override
  String get comingSoon => '준비 중';

  @override
  String get comingSoonDesc => '새로운 레벨이 곧 추가됩니다.';

  @override
  String levelNumber(int levelId) {
    return 'Level $levelId';
  }

  @override
  String get gameHint => '힌트';

  @override
  String get hintAdPrompt => '짧은 광고를 시청하고 힌트를 받으시겠어요?\n다음에 발사할 수 있는 화살표가 빛납니다!';

  @override
  String get watchAd => '광고 보기';

  @override
  String get hintRewardMsg => '💡 힌트: 빛나는 화살표를 발사하세요!';

  @override
  String get hintFreeMsg => '💡 무료 힌트! (광고 준비 안 됨)';

  @override
  String get gameUndo => '되돌리기';

  @override
  String get gameRestart => '다시하기';

  @override
  String get gameOver => '실패';

  @override
  String get gameNoHeartsMsg => '하트를 모두 소진했습니다!\n처음부터 다시 시도해 보세요.';

  @override
  String get gameClear => '클리어!';

  @override
  String get gameNextLevel => '다음';

  @override
  String remainingHearts(int hearts) {
    return '남은 하트: $hearts / 3';
  }

  @override
  String get tutorialSkip => '건너뛰기';

  @override
  String get tutorialNext => '다음';

  @override
  String get tutorialStart => '시작하기!';

  @override
  String get tutorialPage1Title => '화살표 터치';

  @override
  String get tutorialPage1Desc =>
      '화살표를 터치해 보드 밖으로 탈출시키세요.\n화살표가 가리키는 방향으로 날아갑니다!';

  @override
  String get tutorialPage2Title => '경로 확인';

  @override
  String get tutorialPage2Desc =>
      '앞길이 뚫려 있어야만 나갈 수 있습니다.\n다른 화살표에 막히면 하트를 잃습니다!';

  @override
  String get tutorialPage3Title => '퍼즐 클리어';

  @override
  String get tutorialPage3Desc => '순서를 고민하고, 모든 화살표를 탈출시켜\n레벨을 클리어 하세요!';
}
