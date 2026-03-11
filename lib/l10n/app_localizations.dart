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
  /// **'Arrow Puzzle Escape'**
  String get appTitle;

  /// No description provided for @menuPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get menuPlay;

  /// No description provided for @menuLevelSelect.
  ///
  /// In en, this message translates to:
  /// **'LEVEL SELECT'**
  String get menuLevelSelect;

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

  /// No description provided for @settingsHaptic.
  ///
  /// In en, this message translates to:
  /// **'Haptic'**
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

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @levelSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT LEVEL'**
  String get levelSelectTitle;

  /// No description provided for @chapterName.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapterIndex}'**
  String chapterName(int chapterIndex);

  /// No description provided for @levelLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get levelLocked;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Lv. {levelId}'**
  String levelNumber(int levelId);

  /// No description provided for @gameHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get gameHint;

  /// No description provided for @gameUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get gameUndo;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @gameNoHeartsMsg.
  ///
  /// In en, this message translates to:
  /// **'You ran out of hearts!'**
  String get gameNoHeartsMsg;

  /// No description provided for @gameRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get gameRestart;

  /// No description provided for @gameMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get gameMenu;

  /// No description provided for @gameClear.
  ///
  /// In en, this message translates to:
  /// **'Level Clear!'**
  String get gameClear;

  /// No description provided for @gameNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get gameNextLevel;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get tutorialNext;

  /// No description provided for @tutorialStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get tutorialStart;

  /// No description provided for @tutorialPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Tap the Arrow'**
  String get tutorialPage1Title;

  /// No description provided for @tutorialPage1Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap an arrow to shoot it out of the board.\nBut be careful!'**
  String get tutorialPage1Desc;

  /// No description provided for @tutorialPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Watch the Path'**
  String get tutorialPage2Title;

  /// No description provided for @tutorialPage2Desc.
  ///
  /// In en, this message translates to:
  /// **'Arrows can only escape if their path is clear.\nIf blocked by another arrow, you lose a heart.'**
  String get tutorialPage2Desc;

  /// No description provided for @tutorialPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Clear the Board'**
  String get tutorialPage3Title;

  /// No description provided for @tutorialPage3Desc.
  ///
  /// In en, this message translates to:
  /// **'Think ahead, find the right order,\nand free all arrows to clear the level!'**
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
