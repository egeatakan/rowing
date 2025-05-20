  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:sensors_plus/sensors_plus.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  import 'package:flutter_gen/gen_l10n/app_localizations.dart';

  import '../difficulty_selector.dart';
  import 'difficulty_selection_screen.dart';

  class RaceScreen extends StatefulWidget {
    final DifficultyLevel newSelectedDifficulty;
    final int? dynamicMatchCount;

    const RaceScreen({
      super.key,
      required this.newSelectedDifficulty,
      this.dynamicMatchCount,
    });

    @override
    State<RaceScreen> createState() => _RaceScreenState();
  }

  class _RaceScreenState extends State<RaceScreen> {
    // ... (diğer state değişkenleriniz aynı kalır) ...
    double playerDistance = 0;
    double botDistance = 0;
    double raceTime = 0.0;
    bool raceFullyOver = false;
    String _currentRaceStatusMessage = ""; // Başlangıçta boş olacak
    String _winner = "";
    bool botFinishedRace = false;
    double? botFinishTime;
    bool playerFinishedRace = false;
    double? playerFinishTimeForStats;
    double previousZ = 0;
    bool firstRead = true;
    Timer? botMovementTimer;
    Timer? mainRaceTimer;
    StreamSubscription<AccelerometerEvent>? sensorSubscription;
    double botSpeed = 5.0;
    int wins = 0;
    int losses = 0;
    int totalRaces = 0;
    double totalTime = 0.0;
    double bestTime = double.infinity;
    bool _isLoadingDifficulty = true; // Başlangıçta true yapalım

    @override
    void initState() {
      super.initState();
      // _currentRaceStatusMessage'ı burada set etmeyelim, build ilk çağrıldığında
      // _isLoadingDifficulty true olacağı için orada l10n ile set edilecek.
      _setupRace();
      loadStats();
    }

    Future<void> _setupRace() async {
      if (!mounted) return;
      // _isLoadingDifficulty zaten true, setState'e gerek yok.
      // _currentRaceStatusMessage build'de ayarlanacak.

      try {
        // _initializeRaceParameters'a context'i build metodundan sonraki bir aşamada,
        // örneğin WidgetsBinding.instance.addPostFrameCallback içinde veya
        // doğrudan build'den sonra çağırarak vermek daha güvenli olabilir.
        // Şimdilik initState sonrası context'in geçerli olduğunu varsayıyoruz.
        // Eğer sorun devam ederse, bu çağrıyı build'den sonra yapmayı düşünebiliriz.
        if (mounted && context.findRenderObject() != null && context.findRenderObject()!.attached) {
          await _initializeRaceParameters(context);
        } else {
          // Context henüz hazır değilse, kısa bir gecikmeyle tekrar dene
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted && context.findRenderObject() != null && context.findRenderObject()!.attached) {
            await _initializeRaceParameters(context);
          } else {
            print("HATA: _setupRace içinde context alınamadı.");
            // Hata durumunda varsayılan bir zorlukla devam et
            botSpeed = 5.5;
            _currentRaceStatusMessage = "Error loading settings, starting with Medium speed!"; // Bu da l10n olmalı
          }
        }
      } catch (e, s) { // Hata ve stack trace'i yakala
        print("HATA: _initializeRaceParameters içinde bir hata oluştu: $e");
        print("Stack trace: $s");
        if (mounted) {
          setState(() {
            botSpeed = 5.5;
            _currentRaceStatusMessage = AppLocalizations.of(context)?.dynamicErrorStartMedium ?? "Error loading settings, starting with Medium speed!";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingDifficulty = false;
          });
          if (!raceFullyOver) {
            startRace();
          }
        }
      }
    }

    Future<void> _initializeRaceParameters(BuildContext context) async {
      final l10n = AppLocalizations.of(context)!;
      print("--- _initializeRaceParameters BAŞLADI ---");
      // ... (metodun geri kalanı büyük ölçüde aynı, l10n kullanımları doğru) ...
      // Sadece _currentRaceStatusMessage atamalarının setState içinde olduğundan emin olalım
      // veya bu metot bittikten sonra _setupRace içinde tek bir setState ile UI güncellensin.
      // Şimdilik setState'leri koruyalım, ama en sonda tek bir setState daha iyi olabilir.

      String tempStatusMessage = l10n.loadingDifficultySettings; // Geçici değişken

      switch (widget.newSelectedDifficulty) {
        case DifficultyLevel.kolay:
          botSpeed = 3.3;
          tempStatusMessage = l10n.easyLevelRaceStarting;
          break;
        case DifficultyLevel.orta:
          botSpeed = 5.5;
          tempStatusMessage = l10n.mediumLevelRaceStarting;
          break;
        case DifficultyLevel.zor:
          botSpeed = 6.8;
          tempStatusMessage = l10n.hardLevelRaceStarting;
          break;
        case DifficultyLevel.dinamik:
          tempStatusMessage = l10n.dynamicDifficultyCalculating;
          // if (mounted) setState(() { _currentRaceStatusMessage = tempStatusMessage; }); // Bu setState'ler kaldırılabilir
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            botSpeed = 5.5;
            tempStatusMessage = l10n.dynamicLoginNeeded;
          } else if (widget.dynamicMatchCount != null && widget.dynamicMatchCount! > 0) {
            try {
              QuerySnapshot history = await FirebaseFirestore.instance
                  .collection('userMatches').doc(user.uid).collection('matches')
                  .orderBy('timestamp', descending: true).limit(widget.dynamicMatchCount!).get();
              if (history.docs.isNotEmpty) {
                double totalTime = 0; int count = 0;
                for (var doc in history.docs) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data != null && data['raceTime'] is num) {
                    totalTime += (data['raceTime'] as num).toDouble();
                    count++;
                  }
                }
                if (count > 0) {
                  double avgTime = totalTime / count;
                  if (avgTime > 0) botSpeed = (100 / avgTime).clamp(3.0, 15.0);
                  else botSpeed = 5.0;
                  tempStatusMessage = l10n.dynamicDifficultyStartMessage(count, botSpeed.toStringAsFixed(1));
                } else { botSpeed = 5.0; tempStatusMessage = l10n.dynamicNoDataStartMedium; }
              } else { botSpeed = 5.5; tempStatusMessage = l10n.dynamicNoHistoryStartMedium; }
            } catch (e) { botSpeed = 5.5; tempStatusMessage = l10n.dynamicErrorStartMedium; print("Dinamik zorluk hatası: $e");}
          } else { botSpeed = 5.5; tempStatusMessage = l10n.dynamicNoMatchCount; }
          break;
      }
      // _currentRaceStatusMessage'ı en sonda bir kez set et
      if(mounted){
        setState(() {
          _currentRaceStatusMessage = tempStatusMessage;
        });
      }
      print("--- _initializeRaceParameters BİTTİ --- Bot Hızı: $botSpeed, Mesaj: $_currentRaceStatusMessage");
    }

    // ... (startRace, _checkAndFinalizeRace, _finalizeRace, _saveMatchResultToFirestore, loadStats, saveStats, dispose, _getLocalizedDifficultyName metodları aynı kalır) ...
    // Bu metotlardaki l10n kullanımlarının context'e göre doğru olduğundan emin olun.

    void startRace() {
      if (!mounted || _isLoadingDifficulty || raceFullyOver) return;
      setState(() {
        playerDistance = 0; botDistance = 0; raceTime = 0.0; raceFullyOver = false;
        _winner = ""; botFinishedRace = false; botFinishTime = null;
        playerFinishedRace = false; playerFinishTimeForStats = null; firstRead = true;
      });
      mainRaceTimer?.cancel(); sensorSubscription?.cancel(); botMovementTimer?.cancel();
      mainRaceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
        if (!mounted || raceFullyOver) { mainRaceTimer?.cancel(); return; }
        if (mounted) setState(() { raceTime += 0.01; });
      });
      sensorSubscription = accelerometerEvents.listen((event) {
        if (raceFullyOver || playerFinishedRace || !mounted) return;
        double currentZ = event.z;
        if (firstRead) { previousZ = currentZ; firstRead = false; return; }
        double diff = (currentZ - previousZ).abs();
        previousZ = currentZ;
        if (diff > 0.5) {
          if (mounted) setState(() {
            if (!playerFinishedRace) {
              playerDistance += diff * 0.08;
              if (playerDistance >= 100) {
                playerDistance = 100; playerFinishedRace = true;
                playerFinishTimeForStats = raceTime;
                _checkAndFinalizeRace(context); 
              }
            }
          });
        }
      });
      botMovementTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (botFinishedRace || raceFullyOver || !mounted) { botMovementTimer?.cancel(); return; }
        if (mounted) setState(() {
          botDistance += botSpeed;
          if (botDistance >= 100) {
            botDistance = 100;
            if (!botFinishedRace) {
              botFinishedRace = true; botFinishTime = raceTime;
              botMovementTimer?.cancel();
              final l10n = AppLocalizations.of(context);
              if (l10n != null && !playerFinishedRace && mounted) {
                  setState(() { 
                      _currentRaceStatusMessage = l10n.botFinishedContinueMessage;
                  });
              }
              _checkAndFinalizeRace(context); 
            }
          }
        });
      });
    }

    void _checkAndFinalizeRace(BuildContext context) { 
      if (playerFinishedRace && !raceFullyOver && mounted) { 
        final l10n = AppLocalizations.of(context)!;
        if (botFinishedRace) {
          _winner = (playerFinishTimeForStats! <= botFinishTime!) ? l10n.youLabel : l10n.botLabel;
        } else {
          _winner = l10n.youLabel;
        }
        _finalizeRace(_winner, playerFinishTimeForStats!, context); 
      }
    }

    void _finalizeRace(String winner, double finalPlayerRaceTime, BuildContext dialogContext) async { 
      if (raceFullyOver || !mounted) return;
      final l10n = AppLocalizations.of(dialogContext)!; 
      setState(() {
        raceFullyOver = true;
        _currentRaceStatusMessage = l10n.winnerMessage(winner);
      });
      mainRaceTimer?.cancel(); sensorSubscription?.cancel(); botMovementTimer?.cancel();
      if (mounted) {
          setState(() {
              totalRaces++; totalTime += finalPlayerRaceTime;
              if (winner == l10n.youLabel) {
                  wins++;
                  if (finalPlayerRaceTime < bestTime) bestTime = finalPlayerRaceTime;
              } else {
                  losses++;
              }
          });
      }
      await saveStats();
      await _saveMatchResultToFirestore(winner, finalPlayerRaceTime, dialogContext); 
      if (mounted) { 
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (alertDialogContext) { 
              final dialogL10n = AppLocalizations.of(alertDialogContext)!;
              return AlertDialog(
                title: Text(dialogL10n.winnerMessage(winner)),
                content: Text("${dialogL10n.yourTimeMessage(finalPlayerRaceTime.toStringAsFixed(2))}\n" +
                              (botFinishedRace ? dialogL10n.botTimeMessage(botFinishTime!.toStringAsFixed(2)) : dialogL10n.botNotFinishedMessage)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(alertDialogContext).pop(); 
                      if (mounted) {
                        Navigator.of(context).pushReplacement( 
                          MaterialPageRoute(builder: (context) => const DifficultySelectionScreen()),
                        );
                      }
                    },
                    child: Text(dialogL10n.playAgainButton),
                  ),
                ],
              );
          }
        );
      }
    }

    Future<void> _saveMatchResultToFirestore(String winner, double playerActualRaceTime, BuildContext contextForL10n) async { 
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !mounted) return; 
      final l10n = AppLocalizations.of(contextForL10n); 
      try {
        await FirebaseFirestore.instance
            .collection('userMatches').doc(user.uid).collection('matches').add({
          'timestamp': FieldValue.serverTimestamp(),
          'raceTime': playerActualRaceTime,
          'difficulty': widget.newSelectedDifficulty.name,
          'dynamicMatchCount': widget.newSelectedDifficulty == DifficultyLevel.dinamik
              ? widget.dynamicMatchCount : null,
          'won': winner == (l10n?.youLabel ?? "You"),
          'botFinishTime': botFinishTime,
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( 
            SnackBar(content: Text(l10n?.errorSavingRaceResult(e.toString()) ?? 'Error saving race result: ${e.toString()}'))
          );
        }
      }
    }

    Future<void> loadStats() async { 
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          wins = prefs.getInt('wins') ?? 0;
          losses = prefs.getInt('losses') ?? 0;
          totalRaces = prefs.getInt('totalRaces') ?? 0;
          totalTime = prefs.getDouble('totalTime') ?? 0.0;
          bestTime = prefs.getDouble('bestTime') ?? double.infinity;
        });
      }
    }
    Future<void> saveStats() async { 
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wins', wins);
      await prefs.setInt('losses', losses);
      await prefs.setInt('totalRaces', totalRaces);
      await prefs.setDouble('totalTime', totalTime);
      if (bestTime != double.infinity) {
        await prefs.setDouble('bestTime', bestTime);
      }
    }
    @override
    void dispose() { 
      botMovementTimer?.cancel();
      mainRaceTimer?.cancel();
      sensorSubscription?.cancel();
      super.dispose();
    }

    String _getLocalizedDifficultyName(BuildContext context, DifficultyLevel level) {
      final l10n = AppLocalizations.of(context)!;
      switch (level) {
        case DifficultyLevel.kolay: return l10n.easy;
        case DifficultyLevel.orta: return l10n.medium;
        case DifficultyLevel.zor: return l10n.hard;
        case DifficultyLevel.dinamik: return l10n.difficultyDynamic;
      }
    }

    @override
    Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      final TextTheme textTheme = Theme.of(context).textTheme;
      final l10n = AppLocalizations.of(context)!;

      String appBarTitle;
      if (widget.newSelectedDifficulty == DifficultyLevel.dinamik) {
        appBarTitle = l10n.dynamicDifficultyAppBarTitle;
      } else {
        appBarTitle = l10n.raceAppBarTitle(_getLocalizedDifficultyName(context, widget.newSelectedDifficulty).toUpperCase());
      }

      String displayedRaceStatusMessage = _currentRaceStatusMessage;
      // build metodunda _isLoadingDifficulty true ise ve _currentRaceStatusMessage henüz l10n ile set edilmemişse,
      // burada l10n ile set edelim.
      if (_isLoadingDifficulty && (_currentRaceStatusMessage.isEmpty || _currentRaceStatusMessage == "Loading...")) {
          displayedRaceStatusMessage = l10n.loadingDifficultySettings;
      }


      if (_isLoadingDifficulty) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            backgroundColor: colorScheme.primaryContainer,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(displayedRaceStatusMessage, style: textTheme.titleMedium),
              ],
            ),
          ),
        );
      }

      // ... (build metodunun geri kalanı aynı kalır) ...
      return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: colorScheme.primaryContainer,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: l10n.statisticsTooltip,
              onPressed: () {
                if (mounted) {
                  showDialog(
                      context: context,
                      builder: (dialogContext) { 
                        final dialogL10n = AppLocalizations.of(dialogContext)!; 
                        return AlertDialog(
                            title: Text(dialogL10n.statisticsTitle),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${dialogL10n.userLabel} ${user?.email ?? dialogL10n.unknownUser}', style: textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                Text('${dialogL10n.totalRaces}: $totalRaces', style: textTheme.bodyMedium),
                                Text('${dialogL10n.wins}: $wins', style: textTheme.bodyMedium),
                                Text('${dialogL10n.losses}: $losses', style: textTheme.bodyMedium),
                                Text('${dialogL10n.bestTime}: ${bestTime == double.infinity ? dialogL10n.notAvailable : dialogL10n.timeSeconds(bestTime.toStringAsFixed(2))}', style: textTheme.bodyMedium),
                                Text('${dialogL10n.avgTime}: ${dialogL10n.timeSeconds((totalRaces > 0 ? totalTime / totalRaces : 0.0).toStringAsFixed(2))}', style: textTheme.bodyMedium),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: Text(dialogL10n.closeButton),
                              )
                            ],
                          );
                      });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logoutTooltip,
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorLoggingOut(e.toString()))),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  raceFullyOver ? l10n.winnerMessage(_winner) : _currentRaceStatusMessage, // displayedRaceStatusMessage yerine _currentRaceStatusMessage
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 8),
                if (user != null)
                  Text("${l10n.racerLabel} ${user.email ?? l10n.unknownUser}", style: textTheme.bodySmall, textAlign: TextAlign.center)
                else 
                  Text("${l10n.racerLabel} ${l10n.unknownUser}", style: textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("${l10n.timeLabel} ${raceTime.toStringAsFixed(2)} s", style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(l10n.youLabel, style: textTheme.titleLarge?.copyWith(color: Colors.green[700])),
                            Text(l10n.botLabel, style: textTheme.titleLarge?.copyWith(color: Colors.red[700])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text("${playerDistance.toStringAsFixed(1)}m", style: textTheme.titleMedium),
                                  LinearProgressIndicator(
                                    value: playerDistance / 100,
                                    backgroundColor: Colors.green.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.rowing, size: 30),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text("${botDistance.toStringAsFixed(1)}m", style: textTheme.titleMedium),
                                  LinearProgressIndicator(
                                    value: botDistance / 100,
                                    backgroundColor: Colors.red.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (raceFullyOver)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(l10n.raceFinishedMessage, style: textTheme.headlineSmall?.copyWith(color: Colors.orangeAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  )
                else if (!playerFinishedRace)
                  Column(
                    children: [
                      Icon(Icons.directions_run, size: 50, color: colorScheme.secondary),
                      const SizedBox(height: 10),
                      Text(botFinishedRace ? l10n.botFinishedContinueMessage : l10n.keepRowingMessage, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  )
                else if (playerFinishedRace && !raceFullyOver)
                    Center(child: Text(l10n.calculatingResultsMessage)),
              ],
            ),
          ),
        ),
      );
    }
  }
