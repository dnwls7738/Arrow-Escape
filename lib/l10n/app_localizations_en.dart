// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arrow Puzzle Escape';

  @override
  String get menuPlay => 'PLAY';

  @override
  String get menuLevelSelect => 'LEVEL SELECT';

  @override
  String get menuSettings => 'SETTINGS';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsHaptic => 'Haptic';

  @override
  String get settingsSfx => 'Sound Effects (SFX)';

  @override
  String get settingsBgm => 'Background Music (BGM)';

  @override
  String get settingsDots => 'Show Background Dots';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsClose => 'Close';

  @override
  String get levelSelectTitle => 'SELECT LEVEL';

  @override
  String chapterName(int chapterIndex) {
    return 'Chapter $chapterIndex';
  }

  @override
  String get levelLocked => 'Locked';

  @override
  String levelNumber(int levelId) {
    return 'Lv. $levelId';
  }

  @override
  String get gameHint => 'Hint';

  @override
  String get gameUndo => 'Undo';

  @override
  String get gameOver => 'Game Over';

  @override
  String get gameNoHeartsMsg => 'You ran out of hearts!';

  @override
  String get gameRestart => 'Restart';

  @override
  String get gameMenu => 'Menu';

  @override
  String get gameClear => 'Level Clear!';

  @override
  String get gameNextLevel => 'Next Level';

  @override
  String get tutorialSkip => 'SKIP';

  @override
  String get tutorialNext => 'NEXT';

  @override
  String get tutorialStart => 'START';

  @override
  String get tutorialPage1Title => 'Tap the Arrow';

  @override
  String get tutorialPage1Desc =>
      'Tap an arrow to shoot it out of the board.\nBut be careful!';

  @override
  String get tutorialPage2Title => 'Watch the Path';

  @override
  String get tutorialPage2Desc =>
      'Arrows can only escape if their path is clear.\nIf blocked by another arrow, you lose a heart.';

  @override
  String get tutorialPage3Title => 'Clear the Board';

  @override
  String get tutorialPage3Desc =>
      'Think ahead, find the right order,\nand free all arrows to clear the level!';
}
