// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Sayısal girişler için FilteringTextInputFormatter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Yerelleştirilmiş metinler için AppLocalizations importu
// Bu dosyanın .dart_tool/flutter_gen/gen_l10n/ altında oluşmuş olması gerekir.
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  User? _currentUser;
  bool _isLoading = false;
  // Fotoğraf ile ilgili state'ler bu güncellemede kullanılmıyor.
  // String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null || !mounted) return;
    setState(() { _isLoading = true; });

    try {
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(_currentUser!.uid)
          .get();

      if (mounted && profileDoc.exists) {
        Map<String, dynamic>? data = profileDoc.data() as Map<String, dynamic>?;
        _nameController.text = data?['name'] ?? '';
        _ageController.text = data?['age']?.toString() ?? '';
        _heightController.text = data?['height']?.toString() ?? '';
        _weightController.text = data?['weight']?.toString() ?? '';
        // _profileImageUrl = data?['profileImageUrl']; // Fotoğraf için
      }
    } catch (e) {
      if (mounted) {
        // Bu hata mesajı da yerelleştirilebilir.
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
      Map<String, dynamic> dataToSave = {
        'name': _nameController.text.trim(),
        'email': _currentUser!.email,
        'age': int.tryParse(_ageController.text.trim()),
        'height': int.tryParse(_heightController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()), // Kilo ondalıklı olabilir
        'lastUpdated': FieldValue.serverTimestamp(),
        // if (_profileImageUrl != null) 'profileImageUrl': _profileImageUrl, // Fotoğraf için
      };

      // Boş veya geçersiz sayısal değerler için null ata
      if (_ageController.text.trim().isEmpty) dataToSave['age'] = null;
      if (_heightController.text.trim().isEmpty) dataToSave['height'] = null;
      if (_weightController.text.trim().isEmpty) dataToSave['weight'] = null;


      await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(_currentUser!.uid)
          .set(dataToSave, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Bu mesaj da yerelleştirilebilir.
          const SnackBar(content: Text('Profil başarıyla güncellendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Bu mesaj da yerelleştirilebilir.
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
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Yerelleştirilmiş metinlere erişim için AppLocalizations nesnesini alıyoruz.
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle), // Yerelleştirilmiş başlık
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: _currentUser == null
          ? Center(child: Text(l10n.featureComingSoon)) // Kullanıcı yoksa gösterilecek mesaj
          : _isLoading
              ? const Center(child: CircularProgressIndicator()) // Yükleniyorsa gösterge
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Fotoğraf gösterme ve seçme UI'ı bu adımda kaldırıldı/yorumlandı.
                        // İleride eklenebilir.
                        // const SizedBox(height: 24),
                        Text(
                          l10n.personalInformation, // Yerelleştirilmiş başlık
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        // İsim Alanı
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.name, // Yerelleştirilmiş etiket
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.nameValidationError; // Yerelleştirilmiş hata mesajı
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Yaş Alanı
                        TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: l10n.age, // Yerelleştirilmiş etiket
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Sadece rakam girişi
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              // return l10n.pleaseEnterAge; // Boş bırakılabilir, bu yüzden validasyon kaldırıldı.
                              return null;
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return l10n.numericValidationError; // Yerelleştirilmiş hata mesajı
                            }
                            // İsteğe bağlı: Yaş için min/max değer kontrolü eklenebilir.
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Boy Alanı
                        TextFormField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: l10n.height, // Yerelleştirilmiş etiket
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.height_rounded),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: false),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Sadece rakam girişi
                           validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              // return l10n.pleaseEnterHeight; // Boş bırakılabilir
                              return null;
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return l10n.numericValidationError; // Yerelleştirilmiş hata mesajı
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Kilo Alanı
                        TextFormField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: l10n.weight, // Yerelleştirilmiş etiket
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.monitor_weight_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          // Bir ondalık basamağa veya hiç ondalık basamağa izin ver:
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))],
                           validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              // return l10n.pleaseEnterWeight; // Boş bırakılabilir
                              return null;
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return l10n.numericValidationError; // Yerelleştirilmiş hata mesajı
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                              : const Icon(Icons.save_alt_outlined),
                          label: Text(_isLoading ? 'Kaydediliyor...' : l10n.save), // "Kaydediliyor..." da yerelleştirilebilir.
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
