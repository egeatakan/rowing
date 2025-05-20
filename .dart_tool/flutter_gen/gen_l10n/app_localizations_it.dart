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

  @override
  String get logoutTooltip => 'Esci';

  @override
  String get difficultyLevelTitle => 'Seleziona Livello Difficoltà';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difficile';

  @override
  String get difficultyDynamic => 'Dinamico';

  @override
  String get lastNMatchesPrompt => 'Media di quante ultime partite?';

  @override
  String get exampleHint => 'Es: 3';

  @override
  String get confirmAndStartButton => 'CONFERMA E INIZIA';

  @override
  String get dynamicDifficultyValidationError => 'Inserisci un numero valido e positivo di partite per la difficoltà dinamica.';

  @override
  String get raceSettingsTitle => 'Impostazioni Gara';

  @override
  String get prepareForRaceTitle => 'Preparati per la Gara';

  @override
  String get yourStatisticsTitle => 'Le Tue Statistiche';

  @override
  String get wins => 'Vittorie';

  @override
  String get losses => 'Sconfitte';

  @override
  String get totalRaces => 'Gare Totali';

  @override
  String get avgTime => 'Tempo Medio';

  @override
  String get bestTime => 'Miglior Tempo';

  @override
  String get notAvailable => 'N/D';

  @override
  String get startNewRaceTitle => 'Inizia una Nuova Gara:';

  @override
  String get dynamicDefaultButton => 'Dinamico (Predefinito)';

  @override
  String get refreshDataButton => 'Aggiorna Dati';

  @override
  String timeSeconds(String time) {
    return '${time}s';
  }

  @override
  String get nameValidationError => 'Per favore inserisci il tuo nome.';

  @override
  String get age => 'Età';

  @override
  String get height => 'Altezza (cm)';

  @override
  String get weight => 'Peso (kg)';

  @override
  String get pleaseEnterAge => 'Per favore inserisci la tua età.';

  @override
  String get pleaseEnterHeight => 'Per favore inserisci la tua altezza in cm.';

  @override
  String get pleaseEnterWeight => 'Per favore inserisci il tuo peso in kg.';

  @override
  String get numericValidationError => 'Per favore inserisci un numero valido.';

  @override
  String get loadingRaceInfo => 'Caricamento informazioni gara...';

  @override
  String get loadingDifficultySettings => 'Caricamento impostazioni difficoltà...';

  @override
  String get easyLevelRaceStarting => 'Inizio Gara Livello Facile!';

  @override
  String get mediumLevelRaceStarting => 'Inizio Gara Livello Medio!';

  @override
  String get hardLevelRaceStarting => 'Inizio Gara Livello Difficile!';

  @override
  String get dynamicDifficultyCalculating => 'Calcolo Difficoltà Dinamica...';

  @override
  String dynamicDifficultyStartMessage(int matchCount, String botSpeed) {
    return 'Difficoltà Dinamica (Media Ultime $matchCount Partite)! Velocità Bot: $botSpeed m/s';
  }

  @override
  String get dynamicNoDataStartMedium => 'Dati partita insufficienti per difficoltà dinamica, inizio con velocità Media!';

  @override
  String get dynamicNoHistoryStartMedium => 'Nessuna cronologia partite, inizio con velocità Media!';

  @override
  String get dynamicErrorStartMedium => 'Errore lettura cronologia partite, inizio con velocità Media!';

  @override
  String get dynamicLoginNeeded => 'Accesso non effettuato, inizio con velocità Media!';

  @override
  String get dynamicNoMatchCount => 'Numero partite non specificato per difficoltà dinamica, inizio con velocità Media!';

  @override
  String raceAppBarTitle(String difficultyLevel) {
    return 'Gara Livello $difficultyLevel';
  }

  @override
  String get dynamicDifficultyAppBarTitle => 'GARA DIFFICOLTÀ DINAMICA';

  @override
  String get statisticsTooltip => 'Le Mie Statistiche';

  @override
  String get userLabel => 'Utente:';

  @override
  String get unknownUser => 'Sconosciuto';

  @override
  String get closeButton => 'Chiudi';

  @override
  String get racerLabel => 'Corridore:';

  @override
  String get timeLabel => 'TEMPO:';

  @override
  String get youLabel => 'TU';

  @override
  String get botLabel => 'BOT';

  @override
  String get raceFinishedMessage => '🏁 GARA TERMINATA! 🏁';

  @override
  String get keepRowingMessage => 'Continua a Remare!';

  @override
  String get botFinishedContinueMessage => 'Il Bot ha finito, continua!';

  @override
  String get raceStartingSoonMessage => 'La Gara Sta per Iniziare...';

  @override
  String get calculatingResultsMessage => 'Gara Finita, Calcolo Risultati...';

  @override
  String winnerMessage(String winner) {
    return '$winner Vince!';
  }

  @override
  String yourTimeMessage(String time) {
    return 'Il Tuo Tempo: $time secondi';
  }

  @override
  String botTimeMessage(String time) {
    return 'Tempo Bot: $time secondi';
  }

  @override
  String get botNotFinishedMessage => 'Il Bot non ha ancora finito';

  @override
  String get playAgainButton => 'Gioca Ancora';

  @override
  String errorSavingRaceResult(String error) {
    return 'Errore nel salvataggio del risultato della gara: $error';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Errore di logout: $error';
  }
}
