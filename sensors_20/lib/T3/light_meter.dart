import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';

class LightMeter extends StatefulWidget {
  const LightMeter({super.key});

  @override
  State<LightMeter> createState() => _LightMeterState();
}

class _LightMeterState extends State<LightMeter> {
  int _luxValue = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    try {
      final hasSensor = await LightSensor.hasSensor();
      if (hasSensor) {
        _subscription = LightSensor.luxStream().listen((lux) {
          setState(() => _luxValue = lux);
        });
      } else {
        print("Thiết bị không có cảm biến ánh sáng!");
      }
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Phân loại độ sáng
  String getLightStatus(int lux) {
    if (lux < 10) return "TỐI OM (Phòng kín)";
    if (lux < 500) return "SÁNG VỪA (Trong nhà)";
    return "RẤT SÁNG (Ngoài trời)";
  }

  @override
  Widget build(BuildContext context) {
    // Tự động thay đổi theme app theo ánh sáng môi trường
    final bool isDark = _luxValue < 50;

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      appBar: AppBar(title: const Text("Light Meter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 100,
              color: isDark ? Colors.grey : Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            Text(
              "$_luxValue LUX",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              getLightStatus(_luxValue),
              style: TextStyle(
                fontSize: 24,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
