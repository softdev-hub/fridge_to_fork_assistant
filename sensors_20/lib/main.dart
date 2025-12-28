import 'package:flutter/material.dart';
import 'T1/motion_tracker.dart';
import 'T2/explorer_tool.dart';
import 'T3/light_meter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Thực hành 1: const MotionTracker()
      // Thực hành 2: const ExplorerTool()
      // Thực hành 3: const LightMeter()
      home: const LightMeter(),
    );
  }
}
