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
}
