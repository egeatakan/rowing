// lib/difficulty_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Sayısal giriş formatlayıcıları için

// Bu enum, farklı zorluk seviyelerini temsil eder.
// Bu enum hem DifficultySelectionScreen hem de RaceScreen tarafından kullanılacaktır.
enum DifficultyLevel {
  kolay,
  orta,
  zor,
  dinamik,
}

// Bu widget, kullanıcının zorluk seviyesini seçmesini sağlayan arayüzü oluşturur.
class DifficultySelector extends StatefulWidget {
  const DifficultySelector({super.key, required this.onDifficultySelected});

  // Bu fonksiyon, kullanıcı bir seçim yapıp onayladığında çağrılır.
  // Seçilen zorluk seviyesini (level) ve (dinamikse) maç sayısını (numberOfMatches)
  // bu widget'ı kullanan üst widget'a (DifficultySelectionScreen) iletir.
  final Function(DifficultyLevel level, int? numberOfMatches) onDifficultySelected;

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  // _selectedDifficulty, o anda seçili olan radyo butonunu takip eder.
  // Varsayılan olarak 'kolay' seçilidir.
  DifficultyLevel _selectedDifficulty = DifficultyLevel.kolay;

  // _matchesController, 'Dinamik' zorluk seçildiğinde görünecek olan
  // TextField (metin giriş alanı) widget'ının içeriğini yönetir.
  final TextEditingController _matchesController = TextEditingController();

  // _numberOfMatchesForDynamic, TextField'a girilen sayıyı (tam sayı olarak) tutar.
  int? _numberOfMatchesForDynamic;

  // Bu metot, widget ağaçtan kaldırıldığında (dispose olduğunda) çağrılır.
  // Bellek sızıntılarını önlemek için controller'ı temizleriz.
  @override
  void dispose() {
    _matchesController.dispose();
    super.dispose();
  }

  // Bu metot, kullanıcı bir radyo butonuna tıkladığında çağrılır.
  // Seçilen yeni değeri (_selectedDifficulty) günceller ve arayüzün yeniden çizilmesini sağlar (setState).
  void _handleDifficultyChange(DifficultyLevel? value) {
    if (value != null) {
      setState(() {
        _selectedDifficulty = value;
        // Eğer seçilen zorluk 'Dinamik' değilse, TextField'ı temizle
        // ve _numberOfMatchesForDynamic değerini sıfırla.
        if (_selectedDifficulty != DifficultyLevel.dinamik) {
          _matchesController.clear();
          _numberOfMatchesForDynamic = null;
        }
      });
    }
  }

  // Bu metot, widget'ın arayüzünü oluşturur.
  @override
  Widget build(BuildContext context) {
    // Uygulamanın genel temasından renk ve metin stillerini alalım.
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // İçerideki elemanları yatayda genişlet
      mainAxisSize: MainAxisSize.min, // Sadece kendi içeriği kadar yer kapla
      children: <Widget>[
        // Başlık metni
        Text(
          'Zorluk Seviyesini Seçin:',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary, // Temadan ana rengi al
          ),
          textAlign: TextAlign.center, // Metni ortala
        ),
        const SizedBox(height: 20), // Biraz boşluk bırak

        // Radyo butonlarını daha düzenli göstermek için bir Card widget'ı içinde gruplayalım.
        Card(
          elevation: 2, // Hafif bir gölge efekti
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Köşeleri yuvarlat
          child: Column(
            children: [
              // Her bir zorluk seviyesi için bir RadioListTile
              RadioListTile<DifficultyLevel>(
                title: const Text('Kolay'),
                value: DifficultyLevel.kolay,
                groupValue: _selectedDifficulty, // Hangi radyo butonunun seçili olduğunu belirtir
                onChanged: _handleDifficultyChange, // Tıklandığında çağrılacak metot
                activeColor: colorScheme.primary, // Seçiliyken radyo butonunun rengi
              ),
              RadioListTile<DifficultyLevel>(
                title: const Text('Orta'),
                value: DifficultyLevel.orta,
                groupValue: _selectedDifficulty,
                onChanged: _handleDifficultyChange,
                activeColor: colorScheme.primary,
              ),
              RadioListTile<DifficultyLevel>(
                title: const Text('Zor'),
                value: DifficultyLevel.zor,
                groupValue: _selectedDifficulty,
                onChanged: _handleDifficultyChange,
                activeColor: colorScheme.primary,
              ),
              RadioListTile<DifficultyLevel>(
                title: const Text('Dinamik'),
                value: DifficultyLevel.dinamik,
                groupValue: _selectedDifficulty,
                onChanged: _handleDifficultyChange,
                activeColor: colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16), // Boşluk

        // Eğer 'Dinamik' zorluk seçilmişse, maç sayısını girmek için bir TextField göster.
        if (_selectedDifficulty == DifficultyLevel.dinamik)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _matchesController,
              keyboardType: TextInputType.number, // Sadece sayısal klavye
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly // Sadece rakam girişine izin ver
              ],
              decoration: InputDecoration(
                labelText: 'Son kaç maçın ortalaması alınsın?',
                hintText: 'Örn: 3 veya 5',
                border: const OutlineInputBorder(), // Kenarlık stili
                prefixIcon: Icon(Icons.format_list_numbered, color: colorScheme.primary),
              ),
              onChanged: (value) {
                // TextField'daki değer değiştikçe _numberOfMatchesForDynamic'i güncelle.
                setState(() {
                  _numberOfMatchesForDynamic = int.tryParse(value);
                });
              },
              textAlign: TextAlign.center, // Metni ortala
            ),
          ),
        const SizedBox(height: 24), // Boşluk

        // "Onayla ve Başla" butonu
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16), // Butonun iç boşluğu
          ),
          onPressed: () {
            // Eğer 'Dinamik' seçilmişse ve geçerli bir sayı girilmemişse uyarı göster.
            if (_selectedDifficulty == DifficultyLevel.dinamik) {
              if (_numberOfMatchesForDynamic == null || _numberOfMatchesForDynamic! <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dinamik zorluk için lütfen geçerli ve pozitif bir maç sayısı girin.'),
                    backgroundColor: colorScheme.error, // Hata rengi
                  ),
                );
                return; // İşlemi durdur
              }
            }
            // Seçilen değerleri widget.onDifficultySelected callback'i ile üst widget'a (DifficultySelectionScreen) ilet.
            widget.onDifficultySelected(_selectedDifficulty, _numberOfMatchesForDynamic);
          },
          child: const Text('SEÇİMİ ONAYLA VE YARIŞA BAŞLA'),
        ),
      ],
    );
  }
}
