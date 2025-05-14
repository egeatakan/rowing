// lib/difficulty_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// AppLocalizations importu
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DifficultyLevel {
  kolay,
  orta,
  zor,
  dinamik, // Bu enum adı aynı kalabilir, ARB anahtarı değişti
}

class DifficultySelector extends StatefulWidget {
  const DifficultySelector({super.key, required this.onDifficultySelected});

  final Function(DifficultyLevel level, int? numberOfMatches) onDifficultySelected;

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  DifficultyLevel _selectedDifficulty = DifficultyLevel.kolay;
  final TextEditingController _matchesController = TextEditingController();
  int? _numberOfMatchesForDynamic;

  @override
  void dispose() {
    _matchesController.dispose();
    super.dispose();
  }

  void _handleDifficultyChange(DifficultyLevel? value) {
    if (value != null) {
      setState(() {
        _selectedDifficulty = value;
        if (_selectedDifficulty != DifficultyLevel.dinamik) {
          _matchesController.clear();
          _numberOfMatchesForDynamic = null;
        }
      });
    }
  }

  String _localizedDifficultyName(BuildContext context, DifficultyLevel level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level) {
      case DifficultyLevel.kolay:
        return l10n.easy;
      case DifficultyLevel.orta:
        return l10n.medium;
      case DifficultyLevel.zor:
        return l10n.hard;
      case DifficultyLevel.dinamik:
        return l10n.difficultyDynamic; // "dynamic" yerine "difficultyDynamic" kullanılıyor
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l10n.difficultyLevelTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: DifficultyLevel.values.map((level) {
              return RadioListTile<DifficultyLevel>(
                title: Text(_localizedDifficultyName(context, level)),
                value: level,
                groupValue: _selectedDifficulty,
                onChanged: _handleDifficultyChange,
                activeColor: colorScheme.primary,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDifficulty == DifficultyLevel.dinamik)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _matchesController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: l10n.lastNMatchesPrompt,
                hintText: l10n.exampleHint,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered, color: colorScheme.primary),
              ),
              onChanged: (value) {
                setState(() {
                  _numberOfMatchesForDynamic = int.tryParse(value);
                });
              },
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            if (_selectedDifficulty == DifficultyLevel.dinamik) {
              if (_numberOfMatchesForDynamic == null || _numberOfMatchesForDynamic! <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dynamicDifficultyValidationError),
                    backgroundColor: colorScheme.error,
                  ),
                );
                return;
              }
            }
            widget.onDifficultySelected(_selectedDifficulty, _numberOfMatchesForDynamic);
          },
          child: Text(l10n.confirmAndStartButton),
        ),
      ],
    );
  }
}
