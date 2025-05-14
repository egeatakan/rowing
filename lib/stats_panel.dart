// lib/widgets/stats_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// difficulty_selector.dart dosyanızın doğru yolda olduğundan emin olun
// Örneğin, lib/difficulty_selector.dart ise:
import '../difficulty_selector.dart';

class StatsPanel extends StatelessWidget {
  final int wins;
  final int losses;
  final int totalRaces;
  final double avgTime;
  final double bestTime;
  // Bu callback, bu panel içinde zorluk seçme butonları varsa kullanılır.
  // StatisticsScreen'de kullanılmıyorsa null olabilir.
  final Function(DifficultyLevel difficulty)? onSelectDifficulty;

  const StatsPanel({
    super.key,
    required this.wins,
    required this.losses,
    required this.totalRaces,
    required this.avgTime,
    required this.bestTime,
    this.onSelectDifficulty,
  });

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1, // Gölge daha da azaltıldı
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Köşe yuvarlaklığı biraz daha azaltıldı
      child: Padding(
        // Kart içi padding minimuma indirildi
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortala
          children: [
            Icon(icon, size: 55, color: colorScheme.primary), // İkon boyutu daha da küçültüldü
            const SizedBox(height: 2), // Boşluk minimuma indirildi
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[700], fontSize: 32), // Metin boyutu bodySmall ve fontSize ile daha da küçültüldü
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // Başlığın tek satırda kalmasını sağla
            ),
            // const SizedBox(height: 1), // Bu boşluk kaldırılabilir veya çok küçük tutulabilir
            Text(
              value,
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22), // Metin boyutu labelLarge ve fontSize ile ayarlandı
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // Değerin tek satırda kalmasını sağla
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.yourStatisticsTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary), // Başlık boyutu titleMedium yapıldı
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10), // Boşluk azaltıldı
          GridView.count(
            crossAxisCount: 3, // Yan yana üç kart
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6, // Kartlar arası yatay boşluk azaltıldı
            mainAxisSpacing: 6,  // Kartlar arası dikey boşluk azaltıldı
            // childAspectRatio'yu artırarak kartların yüksekliğini azaltıyoruz.
            // 2.0 değeri, kartların genişliklerinin yüksekliklerinin iki katı olmasını sağlar (çok basık).
            // 1.8 veya 1.6 gibi değerler daha dengeli olabilir.
            childAspectRatio: 1.8, // Önceki 1.1'den artırıldı, kartlar daha kısa olacak
            children: [
              _buildStatCard(context, l10n.wins, wins.toString(), Icons.emoji_events),
              _buildStatCard(context, l10n.losses, losses.toString(), Icons.sentiment_very_dissatisfied),
              _buildStatCard(context, l10n.totalRaces, totalRaces.toString(), Icons.sports_score),
              _buildStatCard(context, l10n.avgTime, l10n.timeSeconds(avgTime.toStringAsFixed(2)), Icons.timer),
              _buildStatCard(context, l10n.bestTime, bestTime == double.infinity ? l10n.notAvailable : l10n.timeSeconds(bestTime.toStringAsFixed(2)), Icons.star_border_purple500_outlined),
            ],
          ),
          // Zorluk seçme butonları (eğer varsa)
          if (onSelectDifficulty != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.startNewRaceTitle,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Butonların görünümünü de sadeleştirebiliriz veya boyutlarını ayarlayabiliriz.
            // Örneğin, FittedBox kullanarak metinleri sığdırabiliriz.
            FittedBox(
              fit: BoxFit.scaleDown, // Metin taşarsa küçültür
              child: ElevatedButton(
                onPressed: () => onSelectDifficulty!(DifficultyLevel.kolay),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                child: Text(l10n.easy, style: const TextStyle(fontSize: 12)),
              ),
            ),
            // Diğer butonlar için de benzer stil uygulanabilir.
            // Şimdilik sadece bir tanesini örnek olarak değiştirdim.
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => onSelectDifficulty!(DifficultyLevel.orta),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              child: Text(l10n.medium),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => onSelectDifficulty!(DifficultyLevel.zor),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              child: Text(l10n.hard),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => onSelectDifficulty!(DifficultyLevel.dinamik),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
              child: Text(l10n.difficultyDynamic),
            ),
          ]
        ],
      ),
    );
  }
}
