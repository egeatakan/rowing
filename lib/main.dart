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
  double ileriGeri = 0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        ileriGeri = event.z; // z ekseni → ileri geri hareket
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      body: Center(
        child: Text(
          "İleri-Geri: ${ileriGeri.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
