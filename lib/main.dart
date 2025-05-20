import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Google ve Apple ile giriş için paketler
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Platforma özgü kontroller için kIsWeb ve dart:io Platform
import 'package:flutter/foundation.dart' show kIsWeb;
// Mobil platformlar için dart:io Platform importu (web'de hata vermemesi için koşullu import gerekebilir)
// Ancak Flutter 3.7 ve sonrası için doğrudan import genellikle sorun çıkarmaz,
// kIsWeb ile doğru kullanıldığı sürece.
import 'dart:io' show Platform;


import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'screens/main_menu_screen.dart';

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
      initialLocale = const Locale('en');
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
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }
    return MaterialApp(
      title: 'Rowing Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( /* ... Tema ayarlarınız ... */
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
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const MainMenuScreen();
          }
          return const SignInScreen();
        },
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    String title = l10n?.settingsTitle ?? 'Login Error'; 
    String okButton = l10n?.save ?? 'OK'; 

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(okButton),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _firebaseSignIn(Future<UserCredential?> Function() signInMethod) async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    try {
      final UserCredential? userCredential = await signInMethod();
      if (userCredential?.user != null) {
        print("Firebase girişi başarılı: ${userCredential!.user!.uid}");
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Bilinmeyen bir Firebase kimlik doğrulama hatası.");
    } catch (e) {
      _showErrorDialog("Beklenmedik bir hata oluştu: ${e.toString()}");
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<UserCredential?> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return null;
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<UserCredential?> _createUserWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return null;
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        rawNonce: null, 
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    bool showAppleSignInButton = false;
    if (!kIsWeb) { // Eğer web platformu değilse
      if (Platform.isIOS) { // Sadece iOS ise Apple ile Giriş butonunu göster
        showAppleSignInButton = true;
      }
    }

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
                    l10n.appTitle, 
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
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), 
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
                    decoration: InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock_outline)), 
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) { 
                      if (value == null || value.isEmpty) return 'Lütfen şifrenizi girin.';
                      if (value.length < 6) return 'Şifre en az 6 karakter olmalıdır.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: () => _firebaseSignIn(_signInWithEmailAndPassword),
                      child: Text('GİRİŞ YAP'), 
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _firebaseSignIn(_createUserWithEmailAndPassword),
                      child: Text('Yeni Hesap Oluştur'), 
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("VEYA", style: TextStyle(color: Colors.grey.shade600)), 
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Image.asset('assets/google_logo.png', height: 24.0, width: 24.0, errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, size: 24)),
                      label: Text('Google ile Giriş Yap'), 
                      onPressed: () => _firebaseSignIn(_signInWithGoogle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        side: BorderSide(color: Colors.grey.shade300)
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Apple ile Giriş Butonu (Sadece iOS'ta ve web değilse gösterilir)
                    if (showAppleSignInButton) 
                      SignInWithAppleButton(
                        text: "Apple ile Giriş Yap", 
                        height: 48,
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        onPressed: () => _firebaseSignIn(_signInWithApple),
                        style: SignInWithAppleButtonStyle.black,
                      )
                    // Web'de Apple butonu için alternatif bir mesaj göstermiyoruz,
                    // çünkü showAppleSignInButton false olacak ve buton hiç render edilmeyecek.
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
