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

  @override
  String get logoutTooltip => 'Çıkış Yap';

  @override
  String get difficultyLevelTitle => 'Zorluk Seviyesini Seçin';

  @override
  String get easy => 'Kolay';

  @override
  String get medium => 'Orta';

  @override
  String get hard => 'Zor';

  @override
  String get difficultyDynamic => 'Dinamik';

  @override
  String get lastNMatchesPrompt => 'Son kaç maçın ortalaması alınsın?';

  @override
  String get exampleHint => 'Örn: 3';

  @override
  String get confirmAndStartButton => 'SEÇİMİ ONAYLA VE BAŞLA';

  @override
  String get dynamicDifficultyValidationError => 'Dinamik zorluk için lütfen geçerli ve pozitif bir maç sayısı girin.';

  @override
  String get raceSettingsTitle => 'Yarış Ayarları';

  @override
  String get prepareForRaceTitle => 'Yarışa Hazırlan';

  @override
  String get yourStatisticsTitle => 'İstatistiklerin';

  @override
  String get wins => 'Kazandın';

  @override
  String get losses => 'Kaybettin';

  @override
  String get totalRaces => 'Toplam Yarış';

  @override
  String get avgTime => 'Ort. Süre';

  @override
  String get bestTime => 'En İyi Süre';

  @override
  String get notAvailable => 'Yok';

  @override
  String get startNewRaceTitle => 'Yeni Bir Yarışa Başla:';

  @override
  String get dynamicDefaultButton => 'Dinamik (Varsayılan)';

  @override
  String get refreshDataButton => 'Verileri Yenile';

  @override
  String timeSeconds(String time) {
    return '${time}s';
  }

  @override
  String get nameValidationError => 'Lütfen adınızı girin.';

  @override
  String get age => 'Yaş';

  @override
  String get height => 'Boy (cm)';

  @override
  String get weight => 'Kilo (kg)';

  @override
  String get pleaseEnterAge => 'Lütfen yaşınızı girin.';

  @override
  String get pleaseEnterHeight => 'Lütfen boyunuzu cm cinsinden girin.';

  @override
  String get pleaseEnterWeight => 'Lütfen kilonuzu kg cinsinden girin.';

  @override
  String get numericValidationError => 'Lütfen geçerli bir sayı girin.';

  @override
  String get loadingRaceInfo => 'Yarış bilgileri yükleniyor...';

  @override
  String get loadingDifficultySettings => 'Zorluk ayarları yükleniyor...';

  @override
  String get easyLevelRaceStarting => 'Kolay Seviyede Yarış Başlıyor!';

  @override
  String get mediumLevelRaceStarting => 'Orta Seviyede Yarış Başlıyor!';

  @override
  String get hardLevelRaceStarting => 'Zor Seviyede Yarış Başlıyor!';

  @override
  String get dynamicDifficultyCalculating => 'Dinamik Zorluk Hesaplanıyor...';

  @override
  String dynamicDifficultyStartMessage(int matchCount, String botSpeed) {
    return 'Dinamik Zorluk (Son $matchCount Maç Ort.)! Bot Hızı: $botSpeed m/s';
  }

  @override
  String get dynamicNoDataStartMedium => 'Dinamik zorluk için yeterli maç verisi yok, Ortalama hızla yarış başlıyor!';

  @override
  String get dynamicNoHistoryStartMedium => 'Hiç maç geçmişiniz yok, Orta seviyede yarış başlıyor!';

  @override
  String get dynamicErrorStartMedium => 'Maç geçmişi okunurken hata oluştu, Orta seviyede yarış başlıyor!';

  @override
  String get dynamicLoginNeeded => 'Giriş yapılmamış, Orta seviyede yarış başlıyor!';

  @override
  String get dynamicNoMatchCount => 'Dinamik zorluk için maç sayısı belirtilmemiş, Orta seviyede yarış başlıyor!';

  @override
  String raceAppBarTitle(String difficultyLevel) {
    return '$difficultyLevel Seviye Yarış';
  }

  @override
  String get dynamicDifficultyAppBarTitle => 'DİNAMİK ZORLUK YARIŞI';

  @override
  String get statisticsTooltip => 'İstatistiklerim';

  @override
  String get userLabel => 'Kullanıcı:';

  @override
  String get unknownUser => 'Bilinmiyor';

  @override
  String get closeButton => 'Kapat';

  @override
  String get racerLabel => 'Yarışçı:';

  @override
  String get timeLabel => 'SÜRE:';

  @override
  String get youLabel => 'SEN';

  @override
  String get botLabel => 'BOT';

  @override
  String get raceFinishedMessage => '🏁 YARIŞ SONUÇLANDI! 🏁';

  @override
  String get keepRowingMessage => 'Kürek Çekmeye Devam!';

  @override
  String get botFinishedContinueMessage => 'Bot bitirdi, devam et!';

  @override
  String get raceStartingSoonMessage => 'Yarış Başlamak Üzere...';

  @override
  String get calculatingResultsMessage => 'Yarış Bitti, Sonuçlar Hesaplanıyor...';

  @override
  String winnerMessage(String winner) {
    return '$winner Kazandı!';
  }

  @override
  String yourTimeMessage(String time) {
    return 'Senin Süren: $time saniye';
  }

  @override
  String botTimeMessage(String time) {
    return 'Bot Süresi: $time saniye';
  }

  @override
  String get botNotFinishedMessage => 'Bot henüz bitirmedi';

  @override
  String get playAgainButton => 'Tekrar Oyna';

  @override
  String errorSavingRaceResult(String error) {
    return 'Yarış sonucu kaydedilirken bir hata oluştu: $error';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Çıkış hatası: $error';
  }
}
