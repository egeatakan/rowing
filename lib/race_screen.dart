import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../difficulty_selector.dart';
import 'difficulty_selection_screen.dart';

class RaceScreen extends StatefulWidget {
  final DifficultyLevel newSelectedDifficulty;
  final int? dynamicMatchCount;

  const RaceScreen({
    super.key,
    required this.newSelectedDifficulty,
    this.dynamicMatchCount,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  // Yarış durumu
  double playerDistance = 0;
  double botDistance = 0;
  double raceTime = 0.0; // Yarışın başından beri geçen toplam süre
  bool raceFullyOver = false; // Oyuncu 100m'yi tamamladığında true olur
  String _currentRaceStatusMessage = "Yarış bilgileri yükleniyor...";
  String _winner = "";

  // Bot durumu
  bool botFinishedRace = false; // Botun 100m'yi bitirip bitirmediği
  double? botFinishTime;      // Botun 100m'yi bitirme süresi

  // Oyuncu durumu
  bool playerFinishedRace = false; // Oyuncunun 100m'yi bitirip bitirmediği
  double? playerFinishTimeForStats; // Oyuncunun 100m'yi bitirme süresi (istatistik için)


  // Sensör ve Timer'lar
  double previousZ = 0;
  bool firstRead = true;
  Timer? botMovementTimer; // Botun hareketini yöneten timer
  Timer? mainRaceTimer;    // Ana yarış süresini sayan timer
  StreamSubscription<AccelerometerEvent>? sensorSubscription;

  // Diğer state'ler
  double botSpeed = 5.0;
  int wins = 0;
  int losses = 0;
  int totalRaces = 0;
  double totalTime = 0.0;
  double bestTime = double.infinity;
  bool _isLoadingDifficulty = false;

  @override
  void initState() {
    super.initState();
    _setupRace();
    loadStats();
  }

  Future<void> _setupRace() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDifficulty = true;
      _currentRaceStatusMessage = "Zorluk ayarları yükleniyor...";
    });
    await _initializeRaceParameters();
    if (mounted) {
      setState(() {
        _isLoadingDifficulty = false;
      });
      // _initializeRaceParameters bittikten sonra startRace çağrılacak
      // ama sadece _isLoadingDifficulty false ise ve raceFullyOver değilse.
      // Bu kontrol startRace içine de eklenebilir.
      startRace(); // Yarışı başlat
    }
  }

  Future<void> _initializeRaceParameters() async {
    // ... (Önceki _initializeRaceParameters kodu aynı kalacak, sadece printleri temizleyebiliriz) ...
    // Örnek olarak dinamik zorluk kısmı:
    if (widget.newSelectedDifficulty == DifficultyLevel.dinamik) {
      _currentRaceStatusMessage = "Dinamik Zorluk Hesaplanıyor...";
      if (mounted) setState(() {});
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && widget.dynamicMatchCount != null && widget.dynamicMatchCount! > 0) {
        try {
          QuerySnapshot history = await FirebaseFirestore.instance
              .collection('userMatches').doc(user.uid).collection('matches')
              .orderBy('timestamp', descending: true).limit(widget.dynamicMatchCount!).get();
          if (history.docs.isNotEmpty) {
            double totalTime = 0; int count = 0;
            for (var doc in history.docs) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null && data['raceTime'] is num) {
                totalTime += (data['raceTime'] as num).toDouble();
                count++;
              }
            }
            if (count > 0) {
              double avgTime = totalTime / count;
              if (avgTime > 0) botSpeed = (100 / avgTime).clamp(3.0, 15.0); // Max hız 15.0 m/s
              else botSpeed = 5.0;
              _currentRaceStatusMessage = "Dinamik Zorluk! Bot Hızı: ${botSpeed.toStringAsFixed(1)} m/s";
            } else { /* Yeterli veri yoksa varsayılan */ botSpeed = 5.0; _currentRaceStatusMessage = "Veri yok, Ortalama hızla başla"; }
          } else { /* Hiç geçmiş yoksa varsayılan */ botSpeed = 5.5; _currentRaceStatusMessage = "Geçmiş yok, Orta hızla başla"; }
        } catch (e) { /* Hata olursa varsayılan */ botSpeed = 5.5; _currentRaceStatusMessage = "Hata, Orta hızla başla"; print("Dinamik zorluk hatası: $e");}
      } else { /* Kullanıcı yoksa veya maç sayısı geçersizse */ botSpeed = 5.5; _currentRaceStatusMessage = "Orta hızla başla"; }
    } else if (widget.newSelectedDifficulty == DifficultyLevel.kolay) {
        botSpeed = 3.3; _currentRaceStatusMessage = "Kolay Seviyede Yarış Başlıyor!";
    } else if (widget.newSelectedDifficulty == DifficultyLevel.orta) {
        botSpeed = 5.5; _currentRaceStatusMessage = "Orta Seviyede Yarış Başlıyor!";
    } else if (widget.newSelectedDifficulty == DifficultyLevel.zor) {
        botSpeed = 6.8; _currentRaceStatusMessage = "Zor Seviyede Yarış Başlıyor!";
    }
    // ... (Diğer zorluk seviyeleri için de mesajlar güncellenmeli)
    if (mounted) setState(() {});
  }


  void startRace() {
    if (!mounted || _isLoadingDifficulty || raceFullyOver) return;
    print("Yarış Başlatılıyor! Bot Hızı: $botSpeed");
    setState(() {
      playerDistance = 0;
      botDistance = 0;
      raceTime = 0.0;
      raceFullyOver = false;
      _winner = "";
      botFinishedRace = false;
      botFinishTime = null;
      playerFinishedRace = false;
      playerFinishTimeForStats = null;
      firstRead = true;
      // _currentRaceStatusMessage zaten _initializeRaceParameters'da ayarlandı.
      // Yarış başladığında farklı bir mesaj göstermek isterseniz burada güncelleyebilirsiniz.
    });

    mainRaceTimer?.cancel();
    sensorSubscription?.cancel();
    botMovementTimer?.cancel();

    mainRaceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted || raceFullyOver) { // Oyuncu 100m'yi tamamladığında ana timer durur
        mainRaceTimer?.cancel();
        return;
      }
      setState(() {
        raceTime += 0.01;
      });
    });

    sensorSubscription = accelerometerEvents.listen((event) {
      if (raceFullyOver || playerFinishedRace || !mounted) { // Oyuncu 100m'yi bitirdiyse daha fazla ilerlemez
        // sensorSubscription?.cancel(); // Bu burada iptal edilirse, yarış bittikten sonra hala dinleyebilir.
                                     // finishRace içinde iptal etmek daha doğru.
        return;
      }
      // ... (sensörle playerDistance artırma mantığı aynı kalır) ...
      double currentZ = event.z;
      if (firstRead) {
        previousZ = currentZ;
        firstRead = false;
        return;
      }
      double diff = (currentZ - previousZ).abs();
      previousZ = currentZ;

      if (diff > 0.5) {
        setState(() {
          if (!playerFinishedRace) { // Sadece oyuncu henüz bitirmemişse mesafeyi artır
            playerDistance += diff * 0.08;
            if (playerDistance >= 100) {
              playerDistance = 100; // Tam 100'de sabitle
              playerFinishedRace = true;
              playerFinishTimeForStats = raceTime; // Oyuncunun 100m bitirme süresi
              print("Oyuncu 100m'yi ${playerFinishTimeForStats?.toStringAsFixed(2)} saniyede bitirdi.");
              _checkAndFinalizeRace();
            }
          }
        });
      }
    });

    botMovementTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (botFinishedRace || raceFullyOver || !mounted) { // Bot bitirdiyse veya yarış tamamen bittiyse bot durur
        botMovementTimer?.cancel();
        return;
      }
      setState(() {
        botDistance += botSpeed;
        if (botDistance >= 100) {
          botDistance = 100; // Tam 100'de sabitle
          if (!botFinishedRace) { // Sadece ilk bitirişinde set et
            botFinishedRace = true;
            botFinishTime = raceTime;
            botMovementTimer?.cancel(); // Botun timer'ını durdur
            print("Bot 100m'yi ${botFinishTime?.toStringAsFixed(2)} saniyede bitirdi.");
            if (!playerFinishedRace) { // Eğer oyuncu hala yarışıyorsa mesaj göster
                _currentRaceStatusMessage = "Bot yarışı bitirdi! Sen 100m'yi tamamla...";
            }
            _checkAndFinalizeRace();
          }
        }
      });
    });
  }

  void _checkAndFinalizeRace() {
    if (playerFinishedRace && !raceFullyOver) { // Oyuncu 100m'yi bitirdiyse ve yarış sonucu henüz belirlenmediyse
      if (botFinishedRace) { // Eğer bot da bitirmişse, süreleri karşılaştır
        _winner = (playerFinishTimeForStats! <= botFinishTime!) ? "You" : "Bot";
      } else { // Bot henüz bitirmemişse, kazanan oyuncu
        _winner = "You";
      }
      _finalizeRace(_winner, playerFinishTimeForStats!);
    }
    // Eğer sadece bot bitirmişse ve oyuncu devam ediyorsa, _finalizeRace çağrılmaz.
  }

  void _finalizeRace(String winner, double finalPlayerRaceTime) async {
    if (raceFullyOver || !mounted) return;

    setState(() {
      raceFullyOver = true; // Yarışın sonucu artık belli
      _currentRaceStatusMessage = "$winner Kazandı!";
    });

    // Tüm timer ve abonelikleri durdur
    mainRaceTimer?.cancel();
    sensorSubscription?.cancel();
    botMovementTimer?.cancel(); // Zaten bot bitirince durmuş olabilir ama garanti olsun

    // İstatistikleri güncelle (oyuncunun 100m süresiyle)
    setState(() {
      totalRaces++;
      totalTime += finalPlayerRaceTime; // Oyuncunun 100m süresini ekle
      if (winner == "You") {
        wins++;
        if (finalPlayerRaceTime < bestTime) bestTime = finalPlayerRaceTime;
      } else {
        losses++;
      }
    });
    await saveStats(); // Yerel istatistikleri kaydet
    // Firestore'a oyuncunun 100m süresini kaydet
    await _saveMatchResultToFirestore(winner, finalPlayerRaceTime);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("$winner Kazandı!"),
          content: Text("Senin Süren: ${finalPlayerRaceTime.toStringAsFixed(2)} saniye\n" +
                        (botFinishedRace ? "Bot Süresi: ${botFinishTime?.toStringAsFixed(2)} saniye" : "Bot henüz bitirmedi")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const DifficultySelectionScreen()),
                  );
                }
              },
              child: const Text("Tekrar Oyna"),
            ),
          ],
        ),
      );
    }
  }

  // _saveMatchResultToFirestore metodunu güncelleyerek ikinci bir parametre almasını sağla
  Future<void> _saveMatchResultToFirestore(String winner, double playerActualRaceTime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('userMatches').doc(user.uid).collection('matches').add({
        'timestamp': FieldValue.serverTimestamp(),
        'raceTime': playerActualRaceTime, // Oyuncunun 100m'yi tamamlama süresi
        'difficulty': widget.newSelectedDifficulty.name,
        'dynamicMatchCount': widget.newSelectedDifficulty == DifficultyLevel.dinamik
            ? widget.dynamicMatchCount : null,
        'won': winner == "You",
        'botFinishTime': botFinishTime, // Botun bitirme süresini de kaydet (opsiyonel)
      });
      print("Yarış sonucu Firestore'a başarıyla kaydedildi. Oyuncu Süresi: $playerActualRaceTime s");
    } catch (e) {
      print("Firestore'a yarış sonucu kaydedilirken hata oluştu: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yarış sonucu kaydedilirken bir hata oluştu: ${e.toString()}')),
        );
      }
    }
  }

  // loadStats, saveStats (yerel), dispose ve build metodları büyük ölçüde aynı kalabilir.
  // Sadece build metodundaki _currentRaceStatusMessage'ın gösterimi ve
  // yarışın bitip bitmediğine dair UI güncellemeleri bu yeni mantığa göre ayarlanabilir.

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        wins = prefs.getInt('wins') ?? 0;
        losses = prefs.getInt('losses') ?? 0;
        totalRaces = prefs.getInt('totalRaces') ?? 0;
        totalTime = prefs.getDouble('totalTime') ?? 0.0;
        bestTime = prefs.getDouble('bestTime') ?? double.infinity;
      });
    }
  }

  Future<void> saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wins', wins);
    await prefs.setInt('losses', losses);
    await prefs.setInt('totalRaces', totalRaces);
    await prefs.setDouble('totalTime', totalTime);
    if (bestTime != double.infinity) {
      await prefs.setDouble('bestTime', bestTime);
    }
  }

  @override
  void dispose() {
    botMovementTimer?.cancel();
    mainRaceTimer?.cancel();
    sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (_isLoadingDifficulty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.newSelectedDifficulty == DifficultyLevel.dinamik
              ? 'DİNAMİK ZORLUK'
              : '${widget.newSelectedDifficulty.name.toUpperCase()} SEVİYE YARIŞ'),
          backgroundColor: colorScheme.primaryContainer,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(_currentRaceStatusMessage, style: textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.newSelectedDifficulty.name.toUpperCase()} Seviye Yarış'),
        backgroundColor: colorScheme.primaryContainer,
        actions: [ /* ... AppBar actions aynı kalabilir ... */
           IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'İstatistiklerim',
            onPressed: () { /* ... İstatistik dialog kodu aynı kalabilir ... */
              if (mounted) {
                 showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('İstatistiklerim'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kullanıcı: ${user?.email ?? 'Bilinmiyor'}', style: textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Text('Toplam Yarış: $totalRaces', style: textTheme.bodyMedium),
                              Text('Kazandıkların: $wins', style: textTheme.bodyMedium),
                              Text('Kaybettiklerin: $losses', style: textTheme.bodyMedium),
                              Text('En İyi Süre: ${bestTime == double.infinity ? "N/A" : bestTime.toStringAsFixed(2) + " s"}', style: textTheme.bodyMedium),
                              Text('Ortalama Süre: ${(totalRaces > 0 ? totalTime / totalRaces : 0.0).toStringAsFixed(2)} s', style: textTheme.bodyMedium),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Kapat'),
                            )
                          ],
                        ));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Çıkış hatası: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                raceFullyOver ? "$_winner Kazandı!" : _currentRaceStatusMessage, // Duruma göre mesaj
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center
              ),
              const SizedBox(height: 8),
              if (user?.email != null)
                Text("Yarışçı: ${user!.email}", style: textTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 20),

              Card( /* ... Card içeriği aynı kalabilir ... */
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("SÜRE: ${raceTime.toStringAsFixed(2)} s", style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("SEN", style: textTheme.titleLarge?.copyWith(color: Colors.green[700])),
                          Text("BOT", style: textTheme.titleLarge?.copyWith(color: Colors.red[700])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text("${playerDistance.toStringAsFixed(1)}m", style: textTheme.titleMedium),
                                LinearProgressIndicator(
                                  value: playerDistance / 100,
                                  backgroundColor: Colors.green.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.rowing, size: 30),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text("${botDistance.toStringAsFixed(1)}m", style: textTheme.titleMedium),
                                LinearProgressIndicator(
                                  value: botDistance / 100,
                                  backgroundColor: Colors.red.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              if (raceFullyOver)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text("🏁 YARIŞ SONUÇLANDI! 🏁", style: textTheme.headlineSmall?.copyWith(color: Colors.orangeAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                )
              else if (!playerFinishedRace) // Oyuncu henüz bitirmemişse
                 Column(
                   children: [
                     Icon(Icons.directions_run, size: 50, color: colorScheme.secondary),
                     const SizedBox(height: 10),
                     Text(botFinishedRace ? "Bot bitirdi, devam et!" : "Kürek Çekmeye Devam!", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                   ],
                 )
              else if (playerFinishedRace && !raceFullyOver) // Oyuncu bitirdi ama bot hala yarışıyor olabilir (veya sonuç bekleniyor)
                  const Center(child: Text("Yarış Bitti, Sonuçlar Hesaplanıyor...")),
            ],
          ),
        ),
      ),
    );
  }
}
