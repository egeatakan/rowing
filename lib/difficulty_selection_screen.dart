// lib/difficulty_selection_screen.dart
import 'package:flutter/material.dart';
// Aşağıdaki importlar KESİNLİKLE GEREKLİDİR ve dosyaların lib klasöründe olduğunu varsayar:
import 'difficulty_selector.dart'; // DifficultyLevel enum'ı ve DifficultySelector widget'ı için
import 'race_screen.dart';       // RaceScreen widget'ı için
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth işlemleri için (çıkış butonu)

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yarış Ayarları'),
        backgroundColor: colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // Başarılı çıkış sonrası main.dart'taki StreamBuilder
                // otomatik olarak SignInScreen'e yönlendirecektir.
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Çıkış sırasında hata: ${e.toString()}'),
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
                  "Yarışa Hazırlan",
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Bu DifficultySelector widget'ının lib/difficulty_selector.dart dosyasında
                // doğru bir şekilde tanımlandığından emin olun.
                DifficultySelector(
                  onDifficultySelected: (level, numberOfMatches) {
                    print('DifficultySelectionScreen: Seçilen Zorluk: $level, Dinamik Maç Sayısı: $numberOfMatches');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RaceScreen(
                          // RaceScreen'in constructor'ının bu parametreleri
                          // aldığından emin olun.
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
