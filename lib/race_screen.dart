import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Firebase Auth EKLENDİ
import 'stats_panel.dart';

enum Difficulty { easy, medium, hard }

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  // --- Mevcut State Değişkenleriniz ---
  double playerDistance = 0;
  double botDistance = 0;
  double previousZ = 0;
  bool firstRead = true;
  bool raceOver = false;
  Timer? botTimer;
  Timer? raceTimer;
  double raceTime = 0.0;
  StreamSubscription<AccelerometerEvent>? sensorSubscription;
  Difficulty? selectedDifficulty;
  double botSpeed = 0.5;

  int wins = 0;
  int losses = 0;
  int totalRaces = 0;
  double totalTime = 0.0;
  double bestTime = double.infinity;
  // --- Mevcut State Değişkenleriniz Bitiş ---


  @override
  void initState() {
    super.initState();
    loadStats();
  }

  // --- Mevcut Metotlarınız ---
  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences kullanımında setState içinde çağırmak UI güncellemeleri için önemlidir.
    if (mounted) { // Asenkron işlem sonrası widget hala ağaçta mı kontrolü
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
    // bestTime sonsuz değilse kaydet
    if (bestTime != double.infinity) {
        await prefs.setDouble('bestTime', bestTime);
    }
  }

  void startRace() {
    // Yarış başlamadan önce setState ile UI güncellemelerini yap
    setState(() {
      raceOver = false;
      botDistance = 0;
      playerDistance = 0;
      firstRead = true;
      raceTime = 0.0;
    });

    raceTimer?.cancel(); // Önceki timerları iptal et (varsa)
    sensorSubscription?.cancel();
    botTimer?.cancel();

    raceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted) return; // Widget dispose edildiyse timer devam etmesin
      setState(() {
        raceTime += 0.01;
      });
    });

    sensorSubscription = accelerometerEvents.listen((event) {
      if (raceOver || !mounted) return;
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
      if (raceOver || !mounted) return;
      setState(() {
        botDistance += botSpeed;
        if (botDistance >= 100 && !raceOver) {
          finishRace("Bot");
        }
      });
    });
  }

  void finishRace(String winner) async {
     if (raceOver) return; // Yarış zaten bittiyse tekrar bitirme

     setState(() { // raceOver durumunu UI'a yansıtmak için setState içinde
       raceOver = true;
     });

     botTimer?.cancel();
     sensorSubscription?.cancel();
     raceTimer?.cancel();


    // State güncellemelerini setState içine alabiliriz
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
     await saveStats(); // İstatistikleri kaydet


    // Dialog göstermeden önce widget'ın hala mount edilip edilmediğini kontrol et
    if (mounted) {
       showDialog(
        context: context,
        barrierDismissible: false, // Dışarı tıklayarak kapatmayı engelle
        builder: (_) => AlertDialog(
          title: Text("$winner Wins!"),
          content: Text("Time: ${raceTime.toStringAsFixed(2)} seconds"),
          actions: [
            TextButton(
              onPressed: () {
                 Navigator.of(context).pop(); // Dialog'u kapat
                 if (mounted) {
                     setState(() => selectedDifficulty = null); // Zorluk seçim ekranına dön
                 }
              },
              child: const Text("Tekrar Oyna"),
            ),
          ],
        ),
      );
    }
  }

  void selectDifficulty(Difficulty difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      botSpeed = switch (difficulty) {
        Difficulty.easy => 3.3,
        Difficulty.medium => 5.5,
        Difficulty.hard => 6.8,
      };
      startRace(); // startRace zaten setState içeriyor, tekrar sarmaya gerek yok
    });
  }

  @override
  void dispose() {
    // Widget ağaçtan kaldırılırken tüm timer'ları ve stream aboneliklerini iptal et
    botTimer?.cancel();
    raceTimer?.cancel();
    sensorSubscription?.cancel();
    super.dispose();
  }
  // --- Mevcut Metotlarınız Bitiş ---

  // --- build Metodu GÜNCELLENDİ ---
  @override
  Widget build(BuildContext context) {
    double avgTime = totalRaces > 0 ? totalTime / totalRaces : 0.0;
    final user = FirebaseAuth.instance.currentUser; // Giriş yapmış kullanıcıyı al

    // Her durumda bir Scaffold döndürerek AppBar'ı her zaman gösterelim
    return Scaffold(
      appBar: AppBar(
        // Başlığı dinamik olarak ayarla
        title: Text(selectedDifficulty == null ? 'İstatistik & Zorluk Seç' : 'Yarış Devam Ediyor!'),
        // AppBar'ın sağına buton(lar) eklemek için 'actions' listesi
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Çıkış ikonu
            tooltip: 'Çıkış Yap', // Üzerine gelince çıkan yazı
            onPressed: () async { // Butona basılınca çalışacak async fonksiyon
              // Hata yakalama bloğu
              try {
                print('Çıkış yapılıyor...'); // Konsola log yazdır (isteğe bağlı)
                await FirebaseAuth.instance.signOut(); // Firebase'den çıkış yap
                print('Başarıyla çıkış yapıldı.');

                // ÖNEMLİ: Başarılı çıkış sonrası main.dart'taki StreamBuilder
                // değişikliği algılayıp SignInScreen'i otomatik gösterecektir.
                // Burada Navigator işlemi YAPMAYIN.

                // Kullanıcıya başarı mesajı göster (isteğe bağlı)
                if (context.mounted) { // context hala geçerli mi kontrol et
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Başarıyla çıkış yapıldı.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                // Hata olursa konsola yazdır ve kullanıcıya mesaj göster
                print('Çıkış sırasında hata: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Çıkış sırasında bir hata oluştu: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      // Scaffold'un body'si, zorluk seçimine göre değişecek
      body: selectedDifficulty == null
          // 1) Zorluk seçilmemişse: İstatistikleri ve zorluk seçme butonlarını göster
          ? StatsPanel(
              wins: wins,
              losses: losses,
              totalRaces: totalRaces,
              avgTime: avgTime,
              bestTime: bestTime,
              onSelect: selectDifficulty,
            )
          // 2) Zorluk seçilmişse: Yarışın durumunu göster
          : Center(
              child: Padding( // Kenarlardan biraz boşluk bırakmak için
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Giriş yapan kullanıcı bilgisini göster (isteğe bağlı)
                    Text("Kullanıcı: ${user?.email ?? 'Bilinmiyor'}", style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 15),

                    // Yarış bilgileri (mevcut kodunuzdaki gibi)
                    Text("Süre: ${raceTime.toStringAsFixed(2)} s", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    const Text("🚣 You vs 🤖 Bot", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    Text("Senin Mesafen: ${playerDistance.toStringAsFixed(2)} m", style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Text("Bot Mesafesi: ${botDistance.toStringAsFixed(2)} m", style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 40),

                    // Yarış bittiyse mesaj göster
                    if (raceOver)
                      const Text("🏁 Yarış Bitti!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
            ),
      // Arka plan rengini sadece yarış ekranındayken ayarla (isteğe bağlı)
      backgroundColor: selectedDifficulty != null ? Colors.teal.shade50 : null,
    );
  }
  // --- build Metodu Bitiş ---
}

// StatsPanel widget'ınızın burada veya ayrı bir dosyada tanımlı olduğunu varsayıyoruz.
// Eğer aynı dosyadaysa burada kalabilir, değilse import edilmiş olmalı.
// class StatsPanel extends StatelessWidget { ... }