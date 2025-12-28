import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionTracker extends StatefulWidget {
  const MotionTracker({super.key});

  @override
  State<MotionTracker> createState() => _MotionTrackerState();
}

class _MotionTrackerState extends State<MotionTracker> {
  // Biến đếm số lần lắc
  int _shakeCount = 0;
  // Ngưỡng rung lắc (m/s2)
  static const double _shakeThreshold = 15.0;
  DateTime _lastShakeTime = DateTime.now();
  
  // Màu nền thay đổi theo cường độ
  Color _bgColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(title: const Text("Motion Tracker - Shake to Count")),
      body: StreamBuilder<UserAccelerometerEvent>(
        stream: userAccelerometerEventStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final event = snapshot.data!;
          // Tính tổng gia tốc (Pythagoras 3D): Căn bậc 2 của tổng bình phương 3 trục
          // Công thức: a = sqrt(x^2 + y^2 + z^2)
          double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

          // Logic phát hiện lắc
          if (acceleration > _shakeThreshold) {
            final now = DateTime.now();
            // Debounce 500ms: Bỏ qua các dao động dư chấn ngay sau cú lắc chính
            if (now.difference(_lastShakeTime).inMilliseconds > 500) {
              _lastShakeTime = now;
              // Cập nhật trạng thái
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _shakeCount++;
                  _bgColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
                });
              });
            }
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.vibration, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  "SHAKE COUNT: $_shakeCount",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  "Gia tốc hiện tại:\n${acceleration.toStringAsFixed(2)} m/s²",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
