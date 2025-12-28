import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

class ExplorerTool extends StatefulWidget {
  const ExplorerTool({super.key});

  @override
  State<ExplorerTool> createState() => _ExplorerToolState();
}

class _ExplorerToolState extends State<ExplorerTool> {
  String _locationMessage = "Đang lấy vị trí...";
  
  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Hàm xin quyền và lấy vị trí
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Kiểm tra GPS Hardware có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationMessage = "Hãy bật GPS (Location Service)!");
      return;
    }

    // 2. Kiểm tra quyền của Ứng dụng
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationMessage = "Quyền vị trí bị từ chối.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationMessage = "Quyền vị trí bị từ chối vĩnh viễn.\nVào Settings để cấp quyền.");
      return;
    }

    // 3. Lấy tọa độ hiện tại (High Accuracy dùng GPS)
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    setState(() {
      _locationMessage = 
          "Vĩ độ (Lat): ${position.latitude}\nKinh độ (Long): ${position.longitude}\nĐộ cao (Alt): ${position.altitude.toStringAsFixed(1)}m";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Explorer Tool"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Phần 1: Hiển thị GPS
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.blueGrey[900],
            child: Column(
              children: [
                const Icon(Icons.location_on, color: Colors.greenAccent, size: 40),
                const SizedBox(height: 10),
                Text(
                  _locationMessage,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _determinePosition,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Cập nhật vị trí"),
                ),
              ],
            ),
          ),
          
          // Phần 2: La bàn (Magnetometer)
          Expanded(
            child: StreamBuilder<MagnetometerEvent>(
              stream: magnetometerEventStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text("Đang đọc cảm biến từ trường...", 
                          style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }
                
                final event = snapshot.data!;
                // Tính góc hướng bắc (Azimuth) dùng hàm atan2
                double heading = atan2(event.y, event.x); // Kết quả là Radian
                
                // Chuyển sang độ
                double headingDegrees = heading * 180 / pi; 
                if (headingDegrees < 0) headingDegrees += 360;

                // Xác định hướng
                String direction = _getDirection(headingDegrees);

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${headingDegrees.toStringAsFixed(0)}°", 
                        style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
                      Text(direction, 
                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      // Transform.rotate nhận vào Radian
                      Transform.rotate(
                        angle: -heading, // Xoay ngược chiều kim đồng hồ để bù lại góc xoay của điện thoại
                        child: const Icon(Icons.navigation, size: 150, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 20),
                      const Text("Mũi tên luôn hướng về phía BẮC", 
                        style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm chuyển đổi góc sang hướng
  String _getDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return "BẮC (N)";
    if (degrees >= 22.5 && degrees < 67.5) return "ĐÔNG BẮC (NE)";
    if (degrees >= 67.5 && degrees < 112.5) return "ĐÔNG (E)";
    if (degrees >= 112.5 && degrees < 157.5) return "ĐÔNG NAM (SE)";
    if (degrees >= 157.5 && degrees < 202.5) return "NAM (S)";
    if (degrees >= 202.5 && degrees < 247.5) return "TÂY NAM (SW)";
    if (degrees >= 247.5 && degrees < 292.5) return "TÂY (W)";
    return "TÂY BẮC (NW)";
  }
}
