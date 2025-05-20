// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rowing Pro';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String get play => 'PLAY';

  @override
  String get statistics => 'STATISTICS';

  @override
  String get settings => 'SETTINGS';

  @override
  String get exit => 'EXIT';

  @override
  String get profile => 'MY PROFILE';

  @override
  String welcomeMessage(String userName) {
    return 'Welcome, $userName';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get statisticsTitle => 'My Statistics';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get profileTitle => 'User Profile';

  @override
  String get save => 'Save';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get name => 'Your Name';

  @override
  String get featureComingSoon => 'This feature will be added soon.';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get difficultyLevelTitle => 'Select Difficulty Level';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get difficultyDynamic => 'Dynamic';

  @override
  String get lastNMatchesPrompt => 'Average of last how many matches?';

  @override
  String get exampleHint => 'E.g.: 3';

  @override
  String get confirmAndStartButton => 'CONFIRM AND START';

  @override
  String get dynamicDifficultyValidationError => 'Please enter a valid positive number of matches for dynamic difficulty.';

  @override
  String get raceSettingsTitle => 'Race Settings';

  @override
  String get prepareForRaceTitle => 'Prepare for Race';

  @override
  String get yourStatisticsTitle => 'Your Statistics';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get totalRaces => 'Total Races';

  @override
  String get avgTime => 'Avg. Time';

  @override
  String get bestTime => 'Best Time';

  @override
  String get notAvailable => 'N/A';

  @override
  String get startNewRaceTitle => 'Start a New Race:';

  @override
  String get dynamicDefaultButton => 'Dynamic (Default)';

  @override
  String get refreshDataButton => 'Refresh Data';

  @override
  String timeSeconds(String time) {
    return '${time}s';
  }

  @override
  String get nameValidationError => 'Please enter your name.';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height (cm)';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get pleaseEnterAge => 'Please enter your age.';

  @override
  String get pleaseEnterHeight => 'Please enter your height in cm.';

  @override
  String get pleaseEnterWeight => 'Please enter your weight in kg.';

  @override
  String get numericValidationError => 'Please enter a valid number.';

  @override
  String get loadingRaceInfo => 'Loading race info...';

  @override
  String get loadingDifficultySettings => 'Loading difficulty settings...';

  @override
  String get easyLevelRaceStarting => 'Easy Level Race Starting!';

  @override
  String get mediumLevelRaceStarting => 'Medium Level Race Starting!';

  @override
  String get hardLevelRaceStarting => 'Hard Level Race Starting!';

  @override
  String get dynamicDifficultyCalculating => 'Calculating Dynamic Difficulty...';

  @override
  String dynamicDifficultyStartMessage(int matchCount, String botSpeed) {
    return 'Dynamic Difficulty (Avg. Last $matchCount Matches)! Bot Speed: $botSpeed m/s';
  }

  @override
  String get dynamicNoDataStartMedium => 'Not enough match data for dynamic difficulty, starting with Medium speed!';

  @override
  String get dynamicNoHistoryStartMedium => 'No match history, starting with Medium speed!';

  @override
  String get dynamicErrorStartMedium => 'Error reading match history, starting with Medium speed!';

  @override
  String get dynamicLoginNeeded => 'Not logged in, starting with Medium speed!';

  @override
  String get dynamicNoMatchCount => 'Match count not specified for dynamic difficulty, starting with Medium speed!';

  @override
  String raceAppBarTitle(String difficultyLevel) {
    return '$difficultyLevel Level Race';
  }

  @override
  String get dynamicDifficultyAppBarTitle => 'DYNAMIC DIFFICULTY RACE';

  @override
  String get statisticsTooltip => 'My Statistics';

  @override
  String get userLabel => 'User:';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get closeButton => 'Close';

  @override
  String get racerLabel => 'Racer:';

  @override
  String get timeLabel => 'TIME:';

  @override
  String get youLabel => 'YOU';

  @override
  String get botLabel => 'BOT';

  @override
  String get raceFinishedMessage => '🏁 RACE FINISHED! 🏁';

  @override
  String get keepRowingMessage => 'Keep Rowing!';

  @override
  String get botFinishedContinueMessage => 'Bot finished, keep going!';

  @override
  String get raceStartingSoonMessage => 'Race Starting Soon...';

  @override
  String get calculatingResultsMessage => 'Race Over, Calculating Results...';

  @override
  String winnerMessage(String winner) {
    return '$winner Wins!';
  }

  @override
  String yourTimeMessage(String time) {
    return 'Your Time: $time seconds';
  }

  @override
  String botTimeMessage(String time) {
    return 'Bot Time: $time seconds';
  }

  @override
  String get botNotFinishedMessage => 'Bot hasn\'t finished yet';

  @override
  String get playAgainButton => 'Play Again';

  @override
  String errorSavingRaceResult(String error) {
    return 'Error saving race result: $error';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Logout error: $error';
  }
}
