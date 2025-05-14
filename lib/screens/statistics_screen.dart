// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// AppLocalizations importu
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// StatsPanel widget'ını ve DifficultyLevel enum'ını içeren dosyayı import edin
// Bu dosyanın konumuna göre yolu ayarlayın. Örneğin lib/widgets/stats_panel.dart ise:
import '../stats_panel.dart';

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
    final l10n = AppLocalizations.of(context)!; // l10n nesnesini al
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle), // Yerelleştirilmiş başlık
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(0), // StatsPanel kendi padding'ini yönetiyor
                children: [
                  StatsPanel( // Bu widget artık yerelleştirilmiş metinleri kullanıyor
                    wins: _wins,
                    losses: _losses,
                    totalRaces: _totalRaces,
                    avgTime: avgTime,
                    bestTime: _bestTime,
                    // Bu ekranda zorluk seçme butonları olmadığı için onSelectDifficulty gönderilmiyor.
                  ),
                  const SizedBox(height: 20),
                  Padding( // Butonu biraz ortalamak ve kenarlardan boşluk bırakmak için
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.refreshDataButton), // Yerelleştirilmiş metin
                      onPressed: _loadStats,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
