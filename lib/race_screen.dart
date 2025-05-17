import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// difficulty_selector.dart dosyanızın doğru yolda olduğundan emin olun
// Örneğin, lib/difficulty_selector.dart ise:
import '../difficulty_selector.dart';
// Eğer lib/widgets/difficulty_selector.dart ise:
// import '../widgets/difficulty_selector.dart';


// DifficultySelectionScreen importu, yarış sonu dialog'undaki butonların yönlendirmesi için.
// Dosya yolunuzu kontrol edin.
// Eğer lib/screens/difficulty_selection_screen.dart ise:
import 'difficulty_selection_screen.dart';
// Eğer lib/difficulty_selection_screen.dart ise:
// import '../difficulty_selection_screen.dart';


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
  double playerDistance = 0;
  double botDistance = 0;
  double previousZ = 0;
  bool firstRead = true;
  bool raceOver = false;
  Timer? botTimer;
  Timer? raceTimer;
  double raceTime = 0.0;
  StreamSubscription<AccelerometerEvent>? sensorSubscription;
  double botSpeed = 5.0; // Varsayılan bot hızı

  int wins = 0;
  int losses = 0;
  int totalRaces = 0;
  double totalTime = 0.0;
  double bestTime = double.infinity;
  String _currentRaceStatusMessage = "Yarış bilgileri yükleniyor...";
  String _winner = "";
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
      if (!raceOver) {
        startRace();
      }
    }
  }

  Future<void> _initializeRaceParameters() async {
    print("--- _initializeRaceParameters BAŞLADI ---");
    print("Seçilen Zorluk: ${widget.newSelectedDifficulty}");
    if (widget.newSelectedDifficulty == DifficultyLevel.dinamik) {
      print("Dinamik Zorluk Maç Sayısı İsteği: ${widget.dynamicMatchCount}");
    }

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
        if (mounted) setState(() {});

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print("Dinamik zorluk için kullanıcı girişi gerekli. Varsayılan Orta hız (5.5) ayarlandı.");
          botSpeed = 5.5;
          _currentRaceStatusMessage = "Giriş yapılmamış, Orta seviyede yarış başlıyor!";
          break;
        }

        print("Kullanıcı UID: ${user.uid}");
        if (widget.dynamicMatchCount != null && widget.dynamicMatchCount! > 0) {
          try {
            print("Firestore'dan son ${widget.dynamicMatchCount} maç çekiliyor...");
            QuerySnapshot matchHistorySnapshot = await FirebaseFirestore.instance
                .collection('userMatches')
                .doc(user.uid)
                .collection('matches')
                .orderBy('timestamp', descending: true)
                .limit(widget.dynamicMatchCount!)
                .get();

            print("Firestore'dan ${matchHistorySnapshot.docs.length} adet maç dokümanı çekildi.");

            if (matchHistorySnapshot.docs.isNotEmpty) {
              double totalRaceTime = 0;
              int validMatchesCount = 0;
              for (var i = 0; i < matchHistorySnapshot.docs.length; i++) {
                final doc = matchHistorySnapshot.docs[i];
                final data = doc.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('raceTime') && data['raceTime'] is num) {
                  double currentMatchTime = (data['raceTime'] as num).toDouble();
                  print("Maç ${i+1} Süresi: $currentMatchTime s");
                  totalRaceTime += currentMatchTime;
                  validMatchesCount++;
                } else {
                  print("Maç ${i+1} geçersiz raceTime verisi içeriyor veya raceTime yok. Atlanıyor. Data: $data");
                }
              }
              print("Toplam geçerli maç sayısı: $validMatchesCount, Toplam süre: $totalRaceTime s");

              if (validMatchesCount > 0) {
                double averageRaceTime = totalRaceTime / validMatchesCount;
                print("Hesaplanan Ortalama Yarış Süresi: $averageRaceTime s");

                if (averageRaceTime > 0) {
                  double calculatedBotSpeed = 100 / averageRaceTime; // 100 metrelik yarış için
                  print("Hesaplanan Ham Bot Hızı (100/ortalamaSüre): $calculatedBotSpeed m/s");

                  // MAKSİMUM HIZ SINIRI KALDIRILDI, SADECE MİNİMUM SINIR KALDI
                  botSpeed = calculatedBotSpeed.clamp(3.0, double.infinity); // Min 3.0 m/s, maksimum sınır yok
                  // Eğer yine de bir üst sınır isterseniz, örneğin 15.0 m/s:
                  // botSpeed = calculatedBotSpeed.clamp(3.0, 15.0);
                  print("Sınırlandırılmış (Min 3.0) Bot Hızı: $botSpeed m/s");

                  _currentRaceStatusMessage = "Dinamik Zorluk (Son $validMatchesCount Maç Ort.)! Bot Hızı: ${botSpeed.toStringAsFixed(1)} m/s";
                } else {
                  botSpeed = 5.0;
                  _currentRaceStatusMessage = "Dinamik zorluk için geçersiz ortalama süre, Ortalama hız (5.0) ile yarış başlıyor!";
                  print("Ortalama süre <= 0, varsayılan bot hızı (5.0) ayarlandı.");
                }
              } else {
                botSpeed = 5.0;
                _currentRaceStatusMessage = "Dinamik zorluk için geçerli maç verisi bulunamadı, Ortalama hız (5.0) ile yarış başlıyor!";
                print("Geçerli maç sayısı 0, varsayılan bot hızı (5.0) ayarlandı.");
              }
            } else {
              botSpeed = 5.5;
              _currentRaceStatusMessage = "Hiç maç geçmişiniz yok, Orta seviyede yarış başlıyor!";
              print("Hiç maç geçmişi bulunamadı, varsayılan bot hızı (5.5) ayarlandı.");
              if (mounted) {
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                    if(mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dinamik zorluk için hiç maç geçmişiniz bulunamadı. Orta seviyede başlatılıyor.')),
                      );
                    }
                  });
              }
            }
          } catch (e) {
            print("Firestore'dan maç geçmişi okunurken HATA: $e");
            botSpeed = 5.5;
            _currentRaceStatusMessage = "Maç geçmişi okunurken hata oluştu, Orta seviyede yarış başlıyor!";
          }
        } else {
          botSpeed = 5.5;
          _currentRaceStatusMessage = "Dinamik zorluk için maç sayısı belirtilmemiş, Orta seviyede yarış başlıyor!";
          print("Dinamik maç sayısı null veya <=0, varsayılan bot hızı (5.5) ayarlandı.");
        }
        break;
    }
    print("--- _initializeRaceParameters BİTTİ --- Bot Hızı: $botSpeed, Mesaj: $_currentRaceStatusMessage");
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
  }

  Future<void> _saveMatchResultToFirestore(String winner) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Kullanıcı girişi yapılmamış, Firestore'a kayıt yapılamadı.");
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('userMatches')
          .doc(user.uid)
          .collection('matches')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'raceTime': raceTime,
        'difficulty': widget.newSelectedDifficulty.name,
        'dynamicMatchCount': widget.newSelectedDifficulty == DifficultyLevel.dinamik
            ? widget.dynamicMatchCount
            : null,
        'won': winner == "You",
      });
      print("Yarış sonucu Firestore'a başarıyla kaydedildi. Süre: $raceTime s");
    } catch (e) {
      print("Firestore'a yarış sonucu kaydedilirken hata oluştu: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yarış sonucu kaydedilirken bir hata oluştu: ${e.toString()}')),
        );
      }
    }
  }

  void startRace() {
    if (!mounted || _isLoadingDifficulty) return;
    setState(() {
      raceOver = false;
      botDistance = 0;
      playerDistance = 0;
      firstRead = true;
      raceTime = 0.0;
      _winner = "";
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
            _winner = "You";
            finishRace(_winner);
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
          _winner = "Bot";
          finishRace(_winner);
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
    await _saveMatchResultToFirestore(winner);

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

    if (_isLoadingDifficulty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.newSelectedDifficulty == DifficultyLevel.dinamik
              ? 'DİNAMİK ZORLUK' // Veya yerelleştirilmiş
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
              else if (!raceOver && raceTime < 0.01 && !_isLoadingDifficulty)
                 const Center(child: Text("Yarış Başlamak Üzere...")),
            ],
          ),
        ),
      ),
    );
  }
}
