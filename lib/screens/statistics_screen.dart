// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// StatsPanel widget'ını ve DifficultyLevel enum'ını içeren dosyayı import edin
// (DifficultyLevel burada doğrudan kullanılmayacak ama StatsPanel'ın bağımlılığı olabilir)
import '../stats_panel.dart'; // Eğer widgets klasöründeyse
// import 'difficulty_selector.dart'; // Eğer DifficultyLevel enum'ı burada tanımlıysa

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _wins = 0;
  int _losses = 0;
  int _totalRaces = 0;
  double _totalTime = 0.0;
  double _bestTime = double.infinity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _wins = prefs.getInt('wins') ?? 0;
        _losses = prefs.getInt('losses') ?? 0;
        _totalRaces = prefs.getInt('totalRaces') ?? 0;
        _totalTime = prefs.getDouble('totalTime') ?? 0.0;
        _bestTime = prefs.getDouble('bestTime') ?? double.infinity;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avgTime = _totalRaces > 0 ? _totalTime / _totalRaces : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("İstatistiklerim"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator( // Aşağı çekerek yenileme özelliği
              onRefresh: _loadStats,
              child: ListView( // Kaydırılabilir içerik için ListView
                padding: const EdgeInsets.all(8.0), // StatsPanel zaten padding içeriyor olabilir
                children: [
                  StatsPanel(
                    wins: _wins,
                    losses: _losses,
                    totalRaces: _totalRaces,
                    avgTime: avgTime,
                    bestTime: _bestTime,
                    // onSelectDifficulty callback'i burada GEREKLİ DEĞİL,
                    // çünkü bu sayfa sadece istatistik gösteriyor.
                    // StatsPanel'ın constructor'ında onSelectDifficulty opsiyonel olmalı.
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Verileri Yenile"),
                      onPressed: _loadStats,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
