import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KayikYarisi(),
    );
  }
}

class KayikYarisi extends StatefulWidget {
  @override
  State<KayikYarisi> createState() => _KayikYarisiState();
}

class _KayikYarisiState extends State<KayikYarisi> {
  double mesafe = 0;
  double oncekiZ = 0;
  bool ilkVeri = true;

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((AccelerometerEvent event) {
      double z = event.z;

      if (ilkVeri) {
        oncekiZ = z;
        ilkVeri = false;
        return;
      }

      double fark = (z - oncekiZ).abs();
      oncekiZ = z;

      if (fark > 0.5) {
        setState(() {
          mesafe += fark * 0.08; // oranı küçük tuttuk
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Gidilen Mesafe: ${mesafe.toStringAsFixed(2)} m",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text("Tableti ileri geri salla 🛶", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
