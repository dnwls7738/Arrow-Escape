// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ARROW ESCAPE';

  @override
  String get menuPlay => 'PLAY';

  @override
  String get menuSettings => 'SETTINGS';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsGameDisplay => 'GAME AND DISPLAY';

  @override
  String get settingsAccountData => 'ACCOUNT & DATA';

  @override
  String get settingsHaptic => 'Haptic Feedback';

  @override
  String get settingsSfx => 'Sound Effects (SFX)';

  @override
  String get settingsBgm => 'Background Music (BGM)';

  @override
  String get settingsDots => 'Show Background Dots';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get playingAsGuest => 'Playing as Guest';

  @override
  String get guestDescription =>
      'Progress is saved locally.\nSign in to sync your progress!';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signInSuccess => 'Successfully signed in! Syncing...';

  @override
  String get accountRestored =>
      'Welcome back! Your deleted account has been restored. ♻️';

  @override
  String get progressSynced => 'Progress synced! ✅';

  @override
  String get signInApple => 'Sign in with Apple';

  @override
  String get appleSignInSoon => 'Apple Sign-In is coming soon!';

  @override
  String get googleAccount => 'Google Account';

  @override
  String get connected => 'Connected';

  @override
  String get forceUpdateCloud => 'Force Update from Cloud';

  @override
  String get downloadingProgress => 'Downloading progress...';

  @override
  String get downloadComplete => 'Download complete!';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signedOut => 'Signed out.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get resetAllProgress => 'RESET ALL PROGRESS';

  @override
  String get resetProgressTitle => 'Reset Progress';

  @override
  String get resetProgressMsg =>
      'Are you sure you want to delete all your level records and stars?\nThis action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'DELETE';

  @override
  String get allProgressReset => 'All progress has been reset.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountMsg =>
      'This will permanently delete:\n• Your Google account link\n• All cloud-saved progress\n• All local data\n\nThis action CANNOT be undone.';

  @override
  String get deleteAccountBtn => 'DELETE ACCOUNT';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String get reauthPrompt => 'Please sign in again to confirm deletion.';

  @override
  String get reauthCancelled => 'Re-authentication cancelled.';

  @override
  String get accountDeleted => 'Account deleted. Playing as guest.';

  @override
  String get levelSelectTitle => 'SELECT LEVEL';

  @override
  String chapterName(int chapterIndex) {
    return 'CHAPTER $chapterIndex';
  }

  @override
  String get comingSoon => 'COMING SOON';

  @override
  String get comingSoonDesc => 'New nightmare levels coming soon.';

  @override
  String levelNumber(int levelId) {
    return 'Level $levelId';
  }

  @override
  String get gameHint => 'Hint';

  @override
  String get hintAdPrompt =>
      'Watch a short ad to get a hint?\nThe next available arrow will glow!';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get hintRewardMsg => '💡 Hint: The glowing arrow can be fired!';

  @override
  String get hintFreeMsg => '💡 Free hint! (Ad not ready)';

  @override
  String get gameUndo => 'Undo';

  @override
  String get gameRestart => 'Restart';

  @override
  String get gameOver => 'FAILED';

  @override
  String get gameNoHeartsMsg => 'Out of hearts!\nTry again from the start.';

  @override
  String get gameClear => 'CLEAR!';

  @override
  String get gameNextLevel => 'Next';

  @override
  String remainingHearts(int hearts) {
    return 'Remaining Hearts: $hearts / 3';
  }

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Let\'s Play!';

  @override
  String get tutorialPage1Title => 'Tap to Fire';

  @override
  String get tutorialPage1Desc =>
      'Tap an arrow to fire it off the board.\nThe arrow flies in the direction it points.';

  @override
  String get tutorialPage2Title => 'Watch for Blocks';

  @override
  String get tutorialPage2Desc =>
      'An arrow can only fire if there\'s\nnothing blocking its path.\nBlocked lines will shake!';

  @override
  String get tutorialPage3Title => 'Clear & Earn Stars';

  @override
  String get tutorialPage3Desc =>
      'Remove ALL arrows to clear the level.\nFewer mistakes = more stars! ⭐⭐⭐\nUse Undo and Hint if you get stuck.';
}
