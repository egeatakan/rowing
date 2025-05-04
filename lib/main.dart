import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RaceScreen(),
    );
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

  @override
  void initState() {
    super.initState();
  }

  void startRace() {
    raceOver = false;
    botDistance = 0;
    playerDistance = 0;
    firstRead = true;
    raceTime = 0.0;

    // 0.01 saniyelik zamanlayıcı
    raceTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        raceTime += 0.01;
      });
    });

    // sensör
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

    // bot
    botTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (raceOver) return;

      setState(() {
        botDistance += botSpeed;
        if (botDistance >= 100 && !raceOver) {
          finishRace("Bot");
        }
      });
    });
  }

  void finishRace(String winner) {
    raceOver = true;
    botTimer?.cancel();
    sensorSubscription?.cancel();
    raceTimer?.cancel();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$winner Wins!"),
        content: Text("Time: ${raceTime.toStringAsFixed(2)} seconds"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                selectedDifficulty = null;
              });
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
        Difficulty.easy => 6.3,
        Difficulty.medium => 6.5,
        Difficulty.hard => 6.8,
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
    if (selectedDifficulty == null) {
      return Scaffold(
        backgroundColor: Colors.teal.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Select Difficulty", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => selectDifficulty(Difficulty.easy), child: const Text("Easy")),
              ElevatedButton(onPressed: () => selectDifficulty(Difficulty.medium), child: const Text("Medium")),
              ElevatedButton(onPressed: () => selectDifficulty(Difficulty.hard), child: const Text("Hard")),
            ],
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
