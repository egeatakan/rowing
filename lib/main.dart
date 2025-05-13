import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- EKLENDİ
import 'package:firebase_auth/firebase_auth.dart'; // <-- EKLENDİ

import 'firebase_options.dart'; // <-- flutterfire configure tarafından oluşturuldu, EKLENDİ
import 'race_screen.dart';      // Mevcut yarış ekranınız


void main() async { // <-- ASYNC OLARAK GÜNCELLENDİ
  // Flutter ve Firebase'in, uygulama başlamadan önce
  // hazır olduğundan emin oluyoruz.
  WidgetsFlutterBinding.ensureInitialized(); // <-- EKLENDİ
  await Firebase.initializeApp(              // <-- EKLENDİ
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
     // MaterialApp'ı döndürmeye devam ediyoruz,
     // ANCAK 'home' parametresini StreamBuilder kullanarak
     // oturum durumuna göre dinamik hale getiriyoruz.
    return MaterialApp(
      title: 'Rowing Race',
      debugShowCheckedModeBanner: false,
       theme: ThemeData(
          primarySwatch: Colors.blue, // Örnek Tema
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      home: StreamBuilder<User?>(
        // Firebase kimlik doğrulama durumundaki değişiklikleri dinliyoruz.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // Bağlantı bekleniyorsa bir yükleme göstergesi göster
           if (snapshot.connectionState == ConnectionState.waiting) {
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
           }
           
          // Eğer snapshot içinde veri varsa (User nesnesi), kullanıcı giriş yapmış demektir.
          if (snapshot.hasData) {
            // Kullanıcı giriş yapmışsa Ana Yarış Ekranını göster
            return const RaceScreen();
          }
          
          // Eğer snapshot içinde veri yoksa, kullanıcı giriş yapmamış demektir.
          // Kullanıcıya giriş/kayıt ekranını göster.
          return const SignInScreen();
        },
      ),
    );
  }
}


//===================================================================
// ÖRNEK: GİRİŞ / KAYIT EKRANI (SignInScreen)
//===================================================================
// BU WIDGET'I TEMİZ KOD İÇİN AYRI BİR DOSYAYA
// (örn: screens/sign_in_screen.dart) TAŞIMANIZ ÖNERİLİR.
//===================================================================
class SignInScreen extends StatefulWidget {
   const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Form Alanları için Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false; // Butonlara basıldığında yükleme durumu için

 @override
  void dispose() {
   // Widget ağaçtan kaldırıldığında controller'ları temizle
   _emailController.dispose();
   _passwordController.dispose();
    super.dispose();
  }

  // --- FIREBASE METODLARI ---

  // Firebase ile Giriş Yap
  Future<void> _signInWithEmailAndPassword() async {
     if (!mounted) return; // Widget hala ekranda mı kontrolü
     setState(() { _loading = true; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
       // Giriş başarılı olursa, yukarıdaki StreamBuilder bunu otomatik olarak
       // algılayacak ve RaceScreen'i gösterecektir.
    } on FirebaseAuthException catch (e) {
       if (!mounted) return;
       // Yaygın Firebase hatalarını kullanıcıya gösterme
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Giriş hatası: ${e.message ?? "Bilinmeyen bir hata oluştu."}')
          ),
      );
    } catch(e) {
       // Diğer olası hatalar
       if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           backgroundColor: Theme.of(context).colorScheme.error,
           content: Text('Beklenmedik Hata: ${e.toString()}')
           ),
       );
    }
     if (!mounted) return;
     setState(() { _loading = false; }); // İşlem bitince yüklemeyi durdur
  }

  // Firebase ile Yeni Kullanıcı Kaydı Oluştur
  Future<void> _createUserWithEmailAndPassword() async {
     if (!mounted) return;
     setState(() { _loading = true; });
    try {
       await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
       // Kayıt başarılı olursa, StreamBuilder bunu algılayıp RaceScreen'i gösterecek.
    } on FirebaseAuthException catch (e) {
        if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           backgroundColor: Theme.of(context).colorScheme.error,
           content: Text('Kayıt hatası: ${e.message ?? "Bilinmeyen bir hata oluştu."}')
           ),
       );
    } catch(e) {
       if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
           content: Text('Beklenmedik Hata: ${e.toString()}')
           ),
       );
    }
     if (!mounted) return;
     setState(() { _loading = false; });
  }

 // --- ARAYÜZ (BUILD METODU) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap veya Kayıt Ol'),
      ),
      body: Center(
        child: SingleChildScrollView( // Küçük ekranlarda taşmayı önlemek için
           padding: const EdgeInsets.all(24.0),
           child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Butonların genişlemesi için
            children: [
              Text("Rowing App",
               textAlign: TextAlign.center,
               style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 40),
              // Email Alanı
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                 textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),
               // Şifre Alanı
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                obscureText: true,
                 textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),

              // Eğer işlem yapılıyorsa yükleme göstergesi göster,
              // değilse butonları göster.
              if (_loading)
                 const Center(child: CircularProgressIndicator())
              else ...[
                  // Giriş Yap Butonu
                  ElevatedButton(
                    onPressed: _signInWithEmailAndPassword,
                    child: const Text('GİRİŞ YAP'),
                  ),
                   const SizedBox(height: 10),
                   // Hesap Oluştur Butonu
                  TextButton(
                     onPressed: _createUserWithEmailAndPassword,
                    child: const Text('Yeni Hesap Oluştur'),
                   ),
              ]
            ],
           ),
        ),
      ),
    );
  }
}