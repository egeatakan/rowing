import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
// RaceScreen'i doğrudan burada import etmiyoruz, DifficultySelectionScreen üzerinden geçilecek.
import 'difficulty_selection_screen.dart'; // YENİ EKLENEN EKRAN

// SignInScreen'i ayrı bir dosyaya taşıdıysanız (kesinlikle önerilir),
// o dosyadan import edin. Örneğin:
// import 'screens/sign_in_screen.dart'; // Eğer lib/screens/sign_in_screen.dart ise

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rowing Race',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent), // Daha modern bir renk şeması
        useMaterial3: true, // Material 3 tasarımını etkinleştir
        elevatedButtonTheme: ElevatedButtonThemeData( // Genel buton stili
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData( // Genel text buton stili
           style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          )
        ),
        inputDecorationTheme: InputDecorationTheme( // Genel TextField stili
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.blueAccent),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData && snapshot.data != null) {
            // Kullanıcı giriş yapmışsa YENİ Zorluk Seçim Ekranını göster
            return const DifficultySelectionScreen();
          }

          // Kullanıcı giriş yapmamışsa SignInScreen'i göster.
          return const SignInScreen();
        },
      ),
    );
  }
}

//===================================================================
// ÖRNEK: GİRİŞ / KAYIT EKRANI (SignInScreen)
//===================================================================
// BU WIDGET'I TEMİZ KOD İÇİN AYRI BİR DOSYAYA TAŞIMANIZ ÖNERİLİR.
//===================================================================
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>(); // Form validasyonu için

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // String_view errorMessagePrefix DÜZELTİLDİ -> String errorMessagePrefix
  Future<void> _handleAuthOperation(Future<UserCredential> Function() authOperation, String successMessage, String errorMessagePrefix) async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() { _loading = true; });

    try {
      await authOperation();
      // Başarılı işlem sonrası StreamBuilder yönlendirmeyi yapacağı için
      // burada ek bir SnackBar göstermeye genellikle gerek yoktur.
      // if (mounted) {
      //    ScaffoldMessenger.of(context).showSnackBar(
      //      SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      //    );
      // }
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
      'Giriş başarılı!', // Bu mesaj artık gösterilmiyor, StreamBuilder yönlendiriyor.
      'Giriş hatası'
    );
  }

  Future<void> _createUserWithEmailAndPassword() async {
    await _handleAuthOperation(
      () => FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
      'Kayıt başarılı!', // Bu mesaj artık gösterilmiyor, StreamBuilder yönlendiriyor.
      'Kayıt hatası'
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.rowing, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 20),
                  Text(
                    "Rowing Pro",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hesabınıza giriş yapın veya yeni hesap oluşturun",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
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
