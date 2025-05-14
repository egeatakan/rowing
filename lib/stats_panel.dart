// lib/stats_panel.dart
import 'package:flutter/material.dart';
// Bu import ÇOK ÖNEMLİ! Yeni DifficultyLevel enum'ını buradan alıyoruz.
import 'difficulty_selector.dart';

class StatsPanel extends StatelessWidget {
  final int wins;
  final int losses;
  final int totalRaces;
  final double avgTime;
  final double bestTime;
  // onSelect callback'i artık DifficultyLevel tipinde bir parametre almalı.
  // Eğer StatsPanel'ınızda zorluk seçme butonları yoksa bu callback'e ihtiyacınız olmayabilir.
  final Function(DifficultyLevel difficulty)? onSelectDifficulty; // Opsiyonel yaptık

  const StatsPanel({
    super.key,
    required this.wins,
    required this.losses,
    required this.totalRaces,
    required this.avgTime,
    required this.bestTime,
    this.onSelectDifficulty, // Opsiyonel olarak constructor'a eklendi
  });

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: textTheme.labelLarge?.copyWith(color: Colors.grey[700]), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "İstatistiklerin",
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2, // Yan yana iki kart
            shrinkWrap: true, // İçeriğe göre boyutlan
            physics: const NeverScrollableScrollPhysics(), // GridView içinde kaydırmayı engelle
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8, // Kartların en-boy oranı
            children: [
              _buildStatCard(context, "Kazandın", wins.toString(), Icons.emoji_events),
              _buildStatCard(context, "Kaybettin", losses.toString(), Icons.sentiment_very_dissatisfied),
              _buildStatCard(context, "Toplam Yarış", totalRaces.toString(), Icons.sports_score),
              _buildStatCard(context, "Ort. Süre", "${avgTime.toStringAsFixed(2)}s", Icons.timer),
              _buildStatCard(context, "En İyi Süre", bestTime == double.infinity ? "N/A" : "${bestTime.toStringAsFixed(2)}s", Icons.star_border_purple500_outlined),
            ],
          ),
          // Eğer onSelectDifficulty callback'i sağlanmışsa zorluk seçme butonlarını göster
          if (onSelectDifficulty != null) ...[
            const SizedBox(height: 30),
            Text(
              "Yeni Bir Yarışa Başla:",
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onSelectDifficulty!(DifficultyLevel.kolay), // Yeni enum kullanılıyor
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
              child: const Text("Kolay"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => onSelectDifficulty!(DifficultyLevel.orta), // Yeni enum kullanılıyor
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              child: const Text("Orta"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => onSelectDifficulty!(DifficultyLevel.zor), // Yeni enum kullanılıyor
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              child: const Text("Zor"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Dinamik zorluk için maç sayısı girişi bu panelde yönetilmeyecekse,
                // bu butona basıldığında bir uyarı verilebilir veya
                // doğrudan DifficultySelectionScreen'e yönlendirilebilir.
                // Şimdilik sadece DifficultyLevel.dinamik gönderiyoruz,
                // maç sayısı null olacak ve RaceScreen bunu ele alacak.
                onSelectDifficulty!(DifficultyLevel.dinamik);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
              child: const Text("Dinamik (Varsayılan)"),
            ),
          ]
        ],
      ),
    );
  }
}
