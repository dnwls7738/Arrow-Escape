// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '애로우 퍼즐 이스케이프';

  @override
  String get menuPlay => '게임 시작';

  @override
  String get menuLevelSelect => '레벨 선택';

  @override
  String get menuSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsHaptic => '진동 (Haptic)';

  @override
  String get settingsSfx => '효과음 (SFX)';

  @override
  String get settingsBgm => '배경음악 (BGM)';

  @override
  String get settingsDots => '배경 닷 포인트 표시';

  @override
  String get settingsLanguage => '언어 (Language)';

  @override
  String get settingsClose => '닫기';

  @override
  String get levelSelectTitle => '레벨 선택';

  @override
  String chapterName(int chapterIndex) {
    return '챕터 $chapterIndex';
  }

  @override
  String get levelLocked => '잠김';

  @override
  String levelNumber(int levelId) {
    return 'Lv. $levelId';
  }

  @override
  String get gameHint => '힌트';

  @override
  String get gameUndo => '되돌리기';

  @override
  String get gameOver => '게임 오버';

  @override
  String get gameNoHeartsMsg => '하트를 모두 소진했습니다!';

  @override
  String get gameRestart => '다시하기';

  @override
  String get gameMenu => '메뉴';

  @override
  String get gameClear => '레벨 클리어!';

  @override
  String get gameNextLevel => '다음 레벨';

  @override
  String get tutorialSkip => '건너뛰기';

  @override
  String get tutorialNext => '다음';

  @override
  String get tutorialStart => '시작하기';

  @override
  String get tutorialPage1Title => '화살표 터치';

  @override
  String get tutorialPage1Desc => '화살표를 터치해 보드 밖으로 탈출시키세요.\n하지만 조심해야 합니다!';

  @override
  String get tutorialPage2Title => '경로 확인';

  @override
  String get tutorialPage2Desc =>
      '앞길이 뚫려 있어야만 나갈 수 있습니다.\n다른 화살표에 막히면 하트를 잃습니다.';

  @override
  String get tutorialPage3Title => '퍼즐 클리어';

  @override
  String get tutorialPage3Desc => '순서를 고민하고, 모든 화살표를 탈출시켜\n레벨을 클리어 하세요!';
}
