import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rowing Pro'**
  String get appTitle;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get exit;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'MY PROFILE'**
  String get profile;

  /// Welcome message for the user
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}'**
  String welcomeMessage(String userName);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Statistics'**
  String get statisticsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get name;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature will be added soon.'**
  String get featureComingSoon;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// No description provided for @difficultyLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty Level'**
  String get difficultyLevelTitle;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @difficultyDynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get difficultyDynamic;

  /// No description provided for @lastNMatchesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Average of last how many matches?'**
  String get lastNMatchesPrompt;

  /// No description provided for @exampleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: 3'**
  String get exampleHint;

  /// No description provided for @confirmAndStartButton.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM AND START'**
  String get confirmAndStartButton;

  /// No description provided for @dynamicDifficultyValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number of matches for dynamic difficulty.'**
  String get dynamicDifficultyValidationError;

  /// No description provided for @raceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Race Settings'**
  String get raceSettingsTitle;

  /// No description provided for @prepareForRaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for Race'**
  String get prepareForRaceTitle;

  /// No description provided for @yourStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get yourStatisticsTitle;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @totalRaces.
  ///
  /// In en, this message translates to:
  /// **'Total Races'**
  String get totalRaces;

  /// No description provided for @avgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. Time'**
  String get avgTime;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @startNewRaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a New Race:'**
  String get startNewRaceTitle;

  /// No description provided for @dynamicDefaultButton.
  ///
  /// In en, this message translates to:
  /// **'Dynamic (Default)'**
  String get dynamicDefaultButton;

  /// No description provided for @refreshDataButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshDataButton;

  /// Time in seconds
  ///
  /// In en, this message translates to:
  /// **'{time}s'**
  String timeSeconds(String time);

  /// No description provided for @nameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get nameValidationError;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter your age.'**
  String get pleaseEnterAge;

  /// No description provided for @pleaseEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height in cm.'**
  String get pleaseEnterHeight;

  /// No description provided for @pleaseEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight in kg.'**
  String get pleaseEnterWeight;

  /// No description provided for @numericValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get numericValidationError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
