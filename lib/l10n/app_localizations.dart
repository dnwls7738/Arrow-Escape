import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ARROW ESCAPE'**
  String get appTitle;

  /// No description provided for @menuPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get menuPlay;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get menuSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsGameDisplay.
  ///
  /// In en, this message translates to:
  /// **'GAME AND DISPLAY'**
  String get settingsGameDisplay;

  /// No description provided for @settingsAccountData.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT & DATA'**
  String get settingsAccountData;

  /// No description provided for @settingsHaptic.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get settingsHaptic;

  /// No description provided for @settingsSfx.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects (SFX)'**
  String get settingsSfx;

  /// No description provided for @settingsBgm.
  ///
  /// In en, this message translates to:
  /// **'Background Music (BGM)'**
  String get settingsBgm;

  /// No description provided for @settingsDots.
  ///
  /// In en, this message translates to:
  /// **'Show Background Dots'**
  String get settingsDots;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @playingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Playing as Guest'**
  String get playingAsGuest;

  /// No description provided for @guestDescription.
  ///
  /// In en, this message translates to:
  /// **'Progress is saved locally.\nSign in to sync your progress!'**
  String get guestDescription;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @signInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in! Syncing...'**
  String get signInSuccess;

  /// No description provided for @accountRestored.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Your deleted account has been restored. ♻️'**
  String get accountRestored;

  /// No description provided for @progressSynced.
  ///
  /// In en, this message translates to:
  /// **'Progress synced! ✅'**
  String get progressSynced;

  /// No description provided for @signInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInApple;

  /// No description provided for @appleSignInSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In is coming soon!'**
  String get appleSignInSoon;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get googleAccount;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @forceUpdateCloud.
  ///
  /// In en, this message translates to:
  /// **'Force Update from Cloud'**
  String get forceUpdateCloud;

  /// No description provided for @downloadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading progress...'**
  String get downloadingProgress;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete!'**
  String get downloadComplete;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get signedOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @resetAllProgress.
  ///
  /// In en, this message translates to:
  /// **'RESET ALL PROGRESS'**
  String get resetAllProgress;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all your level records and stars?\nThis action cannot be undone.'**
  String get resetProgressMsg;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @allProgressReset.
  ///
  /// In en, this message translates to:
  /// **'All progress has been reset.'**
  String get allProgressReset;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMsg.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:\n• Your Google account link\n• All cloud-saved progress\n• All local data\n\nThis action CANNOT be undone.'**
  String get deleteAccountMsg;

  /// No description provided for @deleteAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccountBtn;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// No description provided for @reauthPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to confirm deletion.'**
  String get reauthPrompt;

  /// No description provided for @reauthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication cancelled.'**
  String get reauthCancelled;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted. Playing as guest.'**
  String get accountDeleted;

  /// No description provided for @levelSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT LEVEL'**
  String get levelSelectTitle;

  /// No description provided for @chapterName.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {chapterIndex}'**
  String chapterName(int chapterIndex);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoon;

  /// No description provided for @comingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'New nightmare levels coming soon.'**
  String get comingSoonDesc;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {levelId}'**
  String levelNumber(int levelId);

  /// No description provided for @gameHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get gameHint;

  /// No description provided for @hintAdPrompt.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to get a hint?\nThe next available arrow will glow!'**
  String get hintAdPrompt;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @hintRewardMsg.
  ///
  /// In en, this message translates to:
  /// **'💡 Hint: The glowing arrow can be fired!'**
  String get hintRewardMsg;

  /// No description provided for @hintFreeMsg.
  ///
  /// In en, this message translates to:
  /// **'💡 Free hint! (Ad not ready)'**
  String get hintFreeMsg;

  /// No description provided for @gameUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get gameUndo;

  /// No description provided for @gameRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get gameRestart;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get gameOver;

  /// No description provided for @gameNoHeartsMsg.
  ///
  /// In en, this message translates to:
  /// **'Out of hearts!\nTry again from the start.'**
  String get gameNoHeartsMsg;

  /// No description provided for @gameClear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR!'**
  String get gameClear;

  /// No description provided for @gameNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get gameNextLevel;

  /// No description provided for @remainingHearts.
  ///
  /// In en, this message translates to:
  /// **'Remaining Hearts: {hearts} / 3'**
  String remainingHearts(int hearts);

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Play!'**
  String get tutorialStart;

  /// No description provided for @tutorialPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Tap to Fire'**
  String get tutorialPage1Title;

  /// No description provided for @tutorialPage1Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap an arrow to fire it off the board.\nThe arrow flies in the direction it points.'**
  String get tutorialPage1Desc;

  /// No description provided for @tutorialPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Watch for Blocks'**
  String get tutorialPage2Title;

  /// No description provided for @tutorialPage2Desc.
  ///
  /// In en, this message translates to:
  /// **'An arrow can only fire if there\'s\nnothing blocking its path.\nBlocked lines will shake!'**
  String get tutorialPage2Desc;

  /// No description provided for @tutorialPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Clear & Earn Stars'**
  String get tutorialPage3Title;

  /// No description provided for @tutorialPage3Desc.
  ///
  /// In en, this message translates to:
  /// **'Remove ALL arrows to clear the level.\nFewer mistakes = more stars! ⭐⭐⭐\nUse Undo and Hint if you get stuck.'**
  String get tutorialPage3Desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
