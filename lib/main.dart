import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
// main_menu_screen.dart dosyanızın doğru yolda olduğundan emin olun
// Örneğin, lib/screens/main_menu_screen.dart ise:
import 'screens/main_menu_screen.dart';
// SignInScreen dosyanızın doğru yolda olduğundan emin olun
// Örneğin, lib/screens/sign_in_screen.dart ise:
// import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  // SharedPreferences anahtarını değiştirmek, eski kaydedilmiş değeri geçersiz kılar.
  // Testler için V2, V3 gibi artırabilirsiniz.
  static const String _selectedLanguageCodeKey = 'selectedLanguageCodeV2';

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_selectedLanguageCodeKey);
    Locale initialLocale;

    if (languageCode != null && languageCode.isNotEmpty) {
      initialLocale = Locale(languageCode);
    } else {
      initialLocale = const Locale('en'); // Varsayılan dil İngilizce
      // Eğer ilk defa varsayılan dil atanıyorsa ve bunu kaydetmek isterseniz:
      // await _saveLocale(initialLocale);
    }

    if (mounted) {
      setState(() {
        _locale = initialLocale;
      });
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageCodeKey, locale.languageCode);
  }

  void setLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
    _saveLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      // _loadLocale tamamlanana kadar kısa bir yükleme ekranı
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      // key: ValueKey(_locale), // <-- BU SATIR KALDIRILDI veya YORUM SATIRI YAPILDI
                               // Navigasyon yığınının sıfırlanmasını önlemek için.
      title: 'Rowing Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
           style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightBlueAccent.shade700, width: 2),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlueAccent.shade100,
          elevation: 2,
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale, // Bu satır, MaterialApp'e hangi dilin kullanılacağını söyler.

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const MainMenuScreen();
          }
          // SignInScreen'in doğru import edildiğinden/tanımlandığından emin olun
          return const SignInScreen();
        },
      ),
    );
  }
}

//===================================================================
// GİRİŞ / KAYIT EKRANI (SignInScreen)
//===================================================================
// Bu widget'ı lib/screens/sign_in_screen.dart gibi ayrı bir dosyaya taşımanız önerilir.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthOperation(Future<UserCredential> Function() authOperation, String errorMessagePrefix) async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() { _loading = true; });
    try {
      await authOperation();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('$errorMessagePrefix: ${e.message ?? "Bilinmeyen bir Firebase hatası."}')
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('Beklenmedik bir hata oluştu: ${e.toString()}')
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() { _loading = false; });
  }

  Future<void> _signInWithEmailAndPassword() async {
    await _handleAuthOperation(
      () => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
      'Giriş hatası'
    );
  }

  Future<void> _createUserWithEmailAndPassword() async {
    await _handleAuthOperation(
      () => FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
      'Kayıt hatası'
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.rowing, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 20),
                  Text(
                    "Rowing Pro",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hesabınıza giriş yapın veya yeni hesap oluşturun",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Lütfen email adresinizi girin.';
                      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'Lütfen geçerli bir email adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Lütfen şifrenizi girin.';
                      if (value.length < 6) return 'Şifre en az 6 karakter olmalıdır.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      child: const Text('GİRİŞ YAP'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _createUserWithEmailAndPassword,
                      child: const Text('Yeni Hesap Oluştur'),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
