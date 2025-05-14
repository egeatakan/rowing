// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator.pop() için
import 'package:firebase_auth/firebase_auth.dart'; // Çıkış ve kullanıcı bilgisi için

// Yerelleştirilmiş metinler için AppLocalizations importu
// Bu dosyanın .dart_tool/flutter_gen/gen_l10n/ altında oluşmuş olması gerekir.
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Diğer ekranlara navigasyon için importlar
// Bu dosyaların konumlarına göre import yollarını kontrol edin.
// Eğer hepsi lib/screens/ altındaysa:
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'user_profile_screen.dart';
// Eğer difficulty_selection_screen.dart lib/ ana dizinindeyse:
import '../difficulty_selection_screen.dart';


class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  // Menü butonu oluşturan yardımcı bir metot
  Widget _buildMenuButton({
    required BuildContext context,
    required String title, // Bu artık yerelleştirilmiş metin olacak
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 60),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    // Yerelleştirilmiş metinlere erişim için AppLocalizations nesnesini alıyoruz.
    // Bu satırın build metodunun içinde olması önemlidir.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mainMenu), // AppBar başlığı yerelleştirildi
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.exit, // Tooltip de yerelleştirilebilir (ARB dosyanıza "logoutTooltip" gibi bir anahtar ekleyerek)
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // main.dart'taki StreamBuilder değişikliği algılayıp
              // SignInScreen'e yönlendirecektir.
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.rowing, size: 100, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                l10n.appTitle, // Uygulama adı yerelleştirildi
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: 8),
                Text(
                  // Karşılama mesajı yerelleştirildi ve kullanıcı adı placeholder'ı kullanıldı
                  l10n.welcomeMessage(user!.displayName ?? user.email!),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: 40),
              _buildMenuButton(
                context: context,
                title: l10n.play, // "OYNA" butonu yerelleştirildi
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DifficultySelectionScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context: context,
                title: l10n.profile, // "PROFİLİM" butonu yerelleştirildi
                icon: Icons.person_rounded,
                color: theme.colorScheme.secondary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context: context,
                title: l10n.statistics, // "İSTATİSTİKLER" butonu yerelleştirildi
                icon: Icons.bar_chart_rounded,
                color: Colors.green[700],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context: context,
                title: l10n.settings, // "AYARLAR" butonu yerelleştirildi
                icon: Icons.settings_rounded,
                color: Colors.orange[700],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context: context,
                title: l10n.exit, // "ÇIKIŞ" butonu yerelleştirildi
                icon: Icons.exit_to_app_rounded,
                color: Colors.red[700],
                onPressed: () {
                  // Uygulamadan çıkış yapar
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
