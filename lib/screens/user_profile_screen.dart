// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için eklendi

// Yerelleştirilmiş metinler için AppLocalizations importu
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  // İleride eklenebilecek diğer kontrolcüler:
  // final TextEditingController _ageController = TextEditingController();
  // final TextEditingController _gymBuddiesProfileController = TextEditingController();

  User? _currentUser;
  bool _isLoading = false;
  String _initialName = ''; // Firestore'dan yüklenen ismi tutmak için

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('userProfiles') // Firestore'daki koleksiyon adı
          .doc(_currentUser!.uid)     // Kullanıcının UID'si ile doküman ID'si
          .get();

      if (mounted && profileDoc.exists) {
        Map<String, dynamic>? data = profileDoc.data() as Map<String, dynamic>?;
        _initialName = data?['name'] ?? '';
        _nameController.text = _initialName;
        // Diğer alanlar da buradan yüklenebilir
        // _ageController.text = data?['age']?.toString() ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil bilgileri yüklenirken hata oluştu: ${e.toString()}')),
        );
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveUserProfile() async {
    if (_currentUser == null || !_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      // Firestore'a kullanıcı profilini kaydet/güncelle
      await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(_currentUser!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _currentUser!.email, // Email'i de saklayabiliriz (Auth'tan geliyor)
        // Diğer kaydedilecek alanlar:
        // 'age': int.tryParse(_ageController.text.trim()),
        // 'lastUpdated': FieldValue.serverTimestamp(), // Son güncelleme zamanı
      }, SetOptions(merge: true)); // merge:true, var olan dokümanı günceller, yoksa yenisini oluşturur.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi!')),
        );
        // Kaydettikten sonra _initialName'i de güncelleyebiliriz
        _initialName = _nameController.text.trim();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellenirken bir hata oluştu: ${e.toString()}')),
        );
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _ageController.dispose();
    // _gymBuddiesProfileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Yerelleştirilmiş metinler için
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle), // Yerelleştirilmiş başlık
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: _currentUser == null
          ? Center(child: Text(l10n.featureComingSoon)) // Veya giriş yapmaya yönlendir
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          l10n.personalInformation, // Yerelleştirilmiş başlık
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.name, // Yerelleştirilmiş etiket
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              // Bu mesajı da ARB dosyanıza ekleyebilirsiniz
                              return 'Lütfen adınızı girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Buraya diğer profil alanları (yaş, boy, kilo, GymBuddies linki vb.) eklenebilir
                        // Örnek:
                        // TextFormField(
                        //   controller: _ageController,
                        //   decoration: InputDecoration(
                        //     labelText: 'Yaşınız', // Yerelleştirin
                        //     border: const OutlineInputBorder(),
                        //     prefixIcon: const Icon(Icons.cake_outlined),
                        //   ),
                        //   keyboardType: TextInputType.number,
                        // ),
                        // const SizedBox(height: 20),
                        // TextFormField(
                        //   controller: _gymBuddiesProfileController,
                        //   decoration: InputDecoration(
                        //     labelText: 'GymBuddies Profil Linki (İsteğe Bağlı)', // Yerelleştirin
                        //     border: const OutlineInputBorder(),
                        //     prefixIcon: const Icon(Icons.link_rounded),
                        //   ),
                        //   keyboardType: TextInputType.url,
                        // ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_alt_outlined),
                          label: Text(_isLoading ? 'Kaydediliyor...' : l10n.save), // Yerelleştirilmiş buton metni
                          onPressed: _isLoading ? null : _saveUserProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
