// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Rowing Pro';

  @override
  String get mainMenu => 'Ana Menü';

  @override
  String get play => 'OYNA';

  @override
  String get statistics => 'İSTATİSTİKLER';

  @override
  String get settings => 'AYARLAR';

  @override
  String get exit => 'ÇIKIŞ';

  @override
  String get profile => 'PROFİLİM';

  @override
  String welcomeMessage(String userName) {
    return 'Hoş geldin, $userName';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get statisticsTitle => 'İstatistiklerim';

  @override
  String get language => 'Dil';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get profileTitle => 'Kullanıcı Profili';

  @override
  String get save => 'Kaydet';

  @override
  String get personalInformation => 'Kişisel Bilgiler';

  @override
  String get name => 'Adınız';

  @override
  String get featureComingSoon => 'Bu özellik yakında eklenecektir.';
}
