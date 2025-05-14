import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'difficulty_selection_screen.dart';
// BU IMPORT SATIRI ÇOK ÖNEMLİ!
// DifficultyLevel enum'ını ve dolayısıyla newSelectedDifficulty parametresinin tipini buradan alır.
// lib/difficulty_selector.dart dosyanızın var olduğundan ve DifficultyLevel enum'ını içerdiğinden emin olun.
import 'difficulty_selector.dart';

// StatsPanel bu ekranda doğrudan kullanılmıyor, ancak istatistikler için
// ayrı bir ekranınız varsa veya farklı bir mantıkla kullanıyorsanız bu import kalabilir.
// import 'stats_panel.dart';

class RaceScreen extends StatefulWidget {
  // DifficultySelectionScreen'den gelen parametreler:
  // BU CONSTRUCTOR'IN DOĞRU OLDUĞUNDAN EMİN OLUN:
  final DifficultyLevel newSelectedDifficulty; // Tipi DifficultyLevel olmalı
  final int? dynamicMatchCount;

  const RaceScreen({
    super.key,
    required this.newSelectedDifficulty, // Bu parametre zorunlu
    this.dynamicMatchCount, // Bu parametre opsiyonel (null olabilir)
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  // --- State Değişkenleri ---
  double playerDistance = 0;
  double botDistance = 0;
  double previousZ = 0;
  bool firstRead = true;
  bool raceOver = false;
  Timer? botTimer;
  Timer? raceTimer;
  double raceTime = 0.0;
  StreamSubscription<AccelerometerEvent>? sensorSubscription;
  double botSpeed = 5.0; // Varsayılan bot hızı, initState'te güncellenecek

  int wins = 0;
  int losses = 0;
  int totalRaces = 0;
  double totalTime = 0.0;
  double bestTime = double.infinity;
  String _currentRaceStatusMessage = "Yarış bilgileri yükleniyor...";

  @override
  void initState() {
    super.initState();
    _initializeRaceParameters(); // Yarış parametrelerini widget'tan gelen değere göre ayarla
    loadStats(); // Kayıtlı istatistikleri yükle

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !raceOver) {
        startRace();
      }
    });
  }

  void _initializeRaceParameters() {
    // Gelen zorluk seviyesine göre bot hızını ve diğer parametreleri ayarla
    // widget.newSelectedDifficulty burada kullanılır.
    switch (widget.newSelectedDifficulty) {
      case DifficultyLevel.kolay:
        botSpeed = 3.3;
        _currentRaceStatusMessage = "Kolay Seviyede Yarış Başlıyor!";
        break;
      case DifficultyLevel.orta:
        botSpeed = 5.5;
        _currentRaceStatusMessage = "Orta Seviyede Yarış Başlıyor!";
        break;
      case DifficultyLevel.zor:
        botSpeed = 6.8;
        _currentRaceStatusMessage = "Zor Seviyede Yarış Başlıyor!";
        break;
      case DifficultyLevel.dinamik:
        _currentRaceStatusMessage = "Dinamik Zorluk Hesaplanıyor...";
        print('Dinamik zorluk seçildi. Maç sayısı: ${widget.dynamicMatchCount}');
        if (widget.dynamicMatchCount != null && widget.dynamicMatchCount! > 0) {
          // TODO: Firebase Firestore'dan son 'widget.dynamicMatchCount' maçın
          // hız/süre verilerini çek. Bu işlem asenkron olmalı.
          // Çekilen verilerden ortalama bir hız hesapla.
          // botSpeed = hesaplananOrtalamaHiz;
          botSpeed = 4.5; // Placeholder
          _currentRaceStatusMessage = "Dinamik Zorluk (Son ${widget.dynamicMatchCount} Maç Ort.) ile Yarış Başlıyor!";
          print('TODO: Firebase\'den son ${widget.dynamicMatchCount} maçın ortalama hızını çek ve botSpeed\'e ata.');
        } else {
          botSpeed = 5.5; // Varsayılan orta
          _currentRaceStatusMessage = "Dinamik zorluk için yetersiz veri, Orta seviyede yarış başlıyor!";
          print('Dinamik zorluk için geçerli maç sayısı yok, varsayılan hız (5.5) ayarlandı.');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dinamik zorluk için yeterli maç geçmişi bulunamadı. Orta seviyede başlatılıyor.')),
              );
            }
          });
        }
        break;
    }
    if (mounted) {
        setState(() {}); // _currentRaceStatusMessage ve botSpeed güncellendiği için UI'ı yenile
    }
  }

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
    // TODO: Firebase'e maç sonucunu kaydetme mantığı eklenecek.
  }

  void startRace() {
    if (!mounted) return;
    setState(() {
      raceOver = false;
      botDistance = 0;
      playerDistance = 0;
      firstRead = true;
      raceTime = 0.0;
    });

    raceTimer?.cancel();
    sensorSubscription?.cancel();
    botTimer?.cancel();

    raceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted || raceOver) {
        raceTimer?.cancel();
        return;
      }
      setState(() {
        raceTime += 0.01;
      });
    });

    sensorSubscription = accelerometerEvents.listen((event) {
      if (raceOver || !mounted) {
        sensorSubscription?.cancel();
        return;
      }
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
          playerDistance += diff * 0.08;
          if (playerDistance >= 100 && !raceOver) {
            finishRace("You");
          }
        });
      }
    });

    botTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (raceOver || !mounted) {
        botTimer?.cancel();
        return;
      }
      setState(() {
        botDistance += botSpeed;
        if (botDistance >= 100 && !raceOver) {
          finishRace("Bot");
        }
      });
    });
  }

  void finishRace(String winner) async {
    if (raceOver) return;

    if (mounted) {
      setState(() {
        raceOver = true;
        _currentRaceStatusMessage = "$winner Kazandı!";
      });
    }

    botTimer?.cancel();
    sensorSubscription?.cancel();
    raceTimer?.cancel();

    if (mounted) {
      setState(() {
        totalRaces++;
        totalTime += raceTime;
        if (winner == "You") {
          wins++;
          if (raceTime < bestTime) bestTime = raceTime;
        } else {
          losses++;
        }
      });
    }
    await saveStats();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("$winner Kazandı!"),
          content: Text("Süre: ${raceTime.toStringAsFixed(2)} saniye"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  // DifficultySelectionScreen'e geri dönmek için import etmeniz gerekebilir.
                  // Eğer DifficultySelectionScreen'i import etmediyseniz, bu satır hata verecektir.
                  // import 'difficulty_selection_screen.dart'; // Gerekirse ekleyin
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

  @override
  void dispose() {
    botTimer?.cancel();
    raceTimer?.cancel();
    sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // widget.newSelectedDifficulty burada kullanılır
        title: Text('${widget.newSelectedDifficulty.name.toUpperCase()} Seviye Yarış'),
        backgroundColor: colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'İstatistiklerim',
            onPressed: () {
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
              Text(_currentRaceStatusMessage, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (user?.email != null)
                Text("Yarışçı: ${user!.email}", style: textTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 20),

              Card(
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

              if (raceOver)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text("🏁 YARIŞ BİTTİ! 🏁", style: textTheme.headlineSmall?.copyWith(color: Colors.orangeAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                )
              else if (!raceOver && raceTime > 0.01)
                 Column(
                   children: [
                     Icon(Icons.directions_run, size: 50, color: colorScheme.secondary),
                     const SizedBox(height: 10),
                     Text("Kürek Çekmeye Devam!", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                   ],
                 )
              else if (!raceOver && raceTime < 0.01)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
