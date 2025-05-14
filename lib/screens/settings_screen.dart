// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
// Yerelleştirilmiş metinler ve MyApp'teki setLocale için
// Bu importların doğru olduğundan emin olun:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// main.dart dosyanızın konumuna göre bu import yolunu ayarlayın.
// Eğer settings_screen.dart lib/screens/ altında ve main.dart lib/ altındaysa:
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _changeLanguage(BuildContext context, String languageCode) {
    Locale newLocale = Locale(languageCode);
    MyApp.setLocale(context, newLocale);
  }

  Widget _buildLanguageTile(BuildContext context, String languageName, String languageCode, String flagEmoji) {
    final theme = Theme.of(context);
    final bool isActive = Localizations.localeOf(context).languageCode == languageCode;

    return Card(
      elevation: isActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isActive ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        title: Text(languageName, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(flagEmoji, style: const TextStyle(fontSize: 24)),
        ),
        trailing: isActive
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () {
          _changeLanguage(context, languageCode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              l10n.selectLanguage,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Dil seçenekleri istediğiniz sırada: İngilizce, İtalyanca, Türkçe
          _buildLanguageTile(context, "English", "en", "🇬🇧"),
          _buildLanguageTile(context, "Italiano", "it", "🇮🇹"),
          _buildLanguageTile(context, "Türkçe", "tr", "🇹🇷"),
          
          const Divider(height: 40, thickness: 1),

          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.secondary),
            title: Text(l10n.featureComingSoon),
            subtitle: const Text("Diğer uygulama ayarları ve kişiselleştirmeler ileride burada olacak."),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
