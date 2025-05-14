// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Rowing Pro';

  @override
  String get mainMenu => 'Menu Principale';

  @override
  String get play => 'GIOCA';

  @override
  String get statistics => 'STATISTICHE';

  @override
  String get settings => 'IMPOSTAZIONI';

  @override
  String get exit => 'ESCI';

  @override
  String get profile => 'IL MIO PROFILO';

  @override
  String welcomeMessage(String userName) {
    return 'Benvenuto, $userName';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get statisticsTitle => 'Le Mie Statistiche';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get profileTitle => 'Profilo Utente';

  @override
  String get save => 'Salva';

  @override
  String get personalInformation => 'Informazioni Personali';

  @override
  String get name => 'Il Tuo Nome';

  @override
  String get featureComingSoon => 'Questa funzione verrà aggiunta presto.';
}
