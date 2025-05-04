import 'package:flutter/material.dart';
import 'race_screen.dart'; // Difficulty enumunu kullanmak için

class StatsPanel extends StatelessWidget {
  final int wins;
  final int losses;
  final int totalRaces;
  final double avgTime;
  final double bestTime;
  final Function(Difficulty) onSelect;

  const StatsPanel({
    super.key,
    required this.wins,
    required this.losses,
    required this.totalRaces,
    required this.avgTime,
    required this.bestTime,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🏆 Statistics",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Wins: $wins"),
            Text("Losses: $losses"),
            Text("Total Races: $totalRaces"),
            Text("Average Time: ${avgTime.toStringAsFixed(2)} s"),
            Text("Best Time: ${bestTime == double.infinity ? 'N/A' : '${bestTime.toStringAsFixed(2)} s'}"),
            const SizedBox(height: 30),
            const Text("Select Difficulty", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => onSelect(Difficulty.easy),
              child: const Text("Easy"),
            ),
            ElevatedButton(
              onPressed: () => onSelect(Difficulty.medium),
              child: const Text("Medium"),
            ),
            ElevatedButton(
              onPressed: () => onSelect(Difficulty.hard),
              child: const Text("Hard"),
            ),
          ],
        ),
      ),
    );
  }
}
