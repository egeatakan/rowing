// lib/difficulty_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// AppLocalizations importu
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Bu importların yollarının doğru olduğundan emin olun
// difficulty_selector.dart dosyanız lib/widgets/ altında veya lib/ ana dizininde olabilir.
// Proje yapınıza göre yolu düzenleyin.
import '../difficulty_selector.dart'; // Eğer lib/difficulty_selector.dart ise
// import '../widgets/difficulty_selector.dart'; // Eğer lib/widgets/difficulty_selector.dart ise
import 'race_screen.dart'; // race_screen.dart dosyanız lib/screens/ altında olduğunu varsayıyorum

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!; // l10n nesnesini al

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.raceSettingsTitle), // Yerelleştirilmiş başlık
        backgroundColor: colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logoutTooltip, // ARB dosyanızda "logoutTooltip" anahtarı olmalı
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // Navigasyon main.dart'taki StreamBuilder tarafından yönetilecek
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Çıkış sırasında hata: ${e.toString()}'), // Bu da yerelleştirilebilir
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings_suggest, size: 60, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  l10n.prepareForRaceTitle, // Yerelleştirilmiş başlık
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // DifficultySelector widget'ının doğru import edildiğinden ve
                // kendisinin de yerelleştirilmiş metinleri kullandığından emin olun.
                DifficultySelector(
                  onDifficultySelected: (level, numberOfMatches) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RaceScreen(
                          newSelectedDifficulty: level,
                          dynamicMatchCount: numberOfMatches,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
