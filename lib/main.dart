import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: RaceScreen());
  }
}

enum Difficulty { easy, medium, hard }

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});
  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  double playerDistance = 0;
  double botDistance = 0;
  double previousZ = 0;
  bool firstRead = true;
  bool raceOver = false;
  Timer? botTimer;
  Timer? raceTimer;
  double raceTime = 0.0;
  StreamSubscription<AccelerometerEvent>? sensorSubscription;
  Difficulty? selectedDifficulty;
  double botSpeed = 0.5;

  int wins = 0;
  int losses = 0;
  int totalRaces = 0;
  double totalTime = 0.0;
  double bestTime = double.infinity;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      wins = prefs.getInt('wins') ?? 0;
      losses = prefs.getInt('losses') ?? 0;
      totalRaces = prefs.getInt('totalRaces') ?? 0;
      totalTime = prefs.getDouble('totalTime') ?? 0.0;
      bestTime = prefs.getDouble('bestTime') ?? double.infinity;
    });
  }

  Future<void> saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wins', wins);
    await prefs.setInt('losses', losses);
    await prefs.setInt('totalRaces', totalRaces);
    await prefs.setDouble('totalTime', totalTime);
    await prefs.setDouble('bestTime', bestTime);
  }

  void startRace() {
    raceOver = false;
    botDistance = 0;
    playerDistance = 0;
    firstRead = true;
    raceTime = 0.0;

    raceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        raceTime += 0.01;
      });
    });

    sensorSubscription = accelerometerEvents.listen((event) {
      if (raceOver) return;

      double currentZ = event.z;
      if (firstRead) {
        previousZ = currentZ;
        firstRead = false;
        return;
      }

      double diff = (currentZ - previousZ).abs();
      previousZ = currentZ;

      if (diff > 0.5) {
        setState(() {
          playerDistance += diff * 0.08;
          if (playerDistance >= 100 && !raceOver) {
            finishRace("You");
          }
        });
      }
    });

    botTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (raceOver) return;
      setState(() {
        botDistance += botSpeed;
        if (botDistance >= 100 && !raceOver) {
          finishRace("Bot");
        }
      });
    });
  }

  void finishRace(String winner) async {
    raceOver = true;
    botTimer?.cancel();
    sensorSubscription?.cancel();
    raceTimer?.cancel();

    totalRaces++;
    totalTime += raceTime;
    if (winner == "You") {
      wins++;
      if (raceTime < bestTime) {
        bestTime = raceTime;
      }
    } else {
      losses++;
    }

    await saveStats();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$winner Wins!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Time: ${raceTime.toStringAsFixed(2)} seconds"),
            if (winner == "You" && raceTime == bestTime)
              const Text("🎉 New Record!", style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => selectedDifficulty = null);
            },
            child: const Text("Play Again"),
          )
        ],
      ),
    );
  }

  void selectDifficulty(Difficulty difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      botSpeed = switch (difficulty) {
        Difficulty.easy => 0.3,
        Difficulty.medium => 0.5,
        Difficulty.hard => 0.8,
      };
      startRace();
    });
  }

  @override
  void dispose() {
    botTimer?.cancel();
    raceTimer?.cancel();
    sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double avgTime = totalRaces > 0 ? totalTime / totalRaces : 0.0;

    if (selectedDifficulty == null) {
      return Scaffold(
        backgroundColor: Colors.teal.shade50,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Select Difficulty", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text("🏆 Wins: $wins    ❌ Losses: $losses", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("📊 Total Races: $totalRaces", style: const TextStyle(fontSize: 16)),
                Text("⏱ Avg. Time: ${avgTime.toStringAsFixed(2)} s", style: const TextStyle(fontSize: 16)),
                Text("🥇 Best Time: ${bestTime == double.infinity ? "N/A" : bestTime.toStringAsFixed(2) + " s"}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: () => selectDifficulty(Difficulty.easy), child: const Text("Easy")),
                ElevatedButton(onPressed: () => selectDifficulty(Difficulty.medium), child: const Text("Medium")),
                ElevatedButton(onPressed: () => selectDifficulty(Difficulty.hard), child: const Text("Hard")),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Difficulty: ${selectedDifficulty!.name.toUpperCase()}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Time: ${raceTime.toStringAsFixed(2)} s", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            const Text("🚣 You vs 🤖 Bot", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text("Your Distance: ${playerDistance.toStringAsFixed(2)} m", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Bot Distance:  ${botDistance.toStringAsFixed(2)} m", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            if (raceOver) const Text("🏁 Race Over", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
