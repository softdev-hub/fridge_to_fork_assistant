# 🟦 CHƯƠNG 20: CẢM BIẾN (SENSORS) VÀ TƯƠNG TÁC THỰC TẾ

> **Mục tiêu:**
> 1. Hiểu sâu về nguyên lý hoạt động của các loại cảm biến (MEMS).
> 2. Nắm vững điều kiện cần và đủ để triển khai ứng dụng cảm biến trên Android/iOS.
> 3. Xây dựng 3 ứng dụng thực tế: Đo bước chân, La bàn GPS, và Đo ánh sáng.
> 4. **Thực hành thực địa:** Sinh viên phải mang điện thoại ra môi trường thực tế để kiểm chứng.

---

## 20.1. Lý thuyết chuyên sâu: Cảm biến hoạt động như thế nào?

Điện thoại không "cảm nhận" như con người, chúng sử dụng công nghệ **MEMS** (Micro-Electro-Mechanical Systems) - những cỗ máy cơ học siêu nhỏ được khắc trên chip silicon.

### 1. Accelerometer (Gia tốc kế) - Đo thay đổi vận tốc
*   **Nguyên lý:** Hãy tưởng tượng một khối quả nặng (`seismic mass`) được treo lơ lửng bởi các lò xo siêu nhỏ bên trong chip.
    *   Khi bạn di chuyển điện thoại, quán tính làm khối nặng này tụt lại phía sau.
    *   Sự dịch chuyển này làm thay đổi điện dung (capacitance) giữa các vách ngăn. Chip đo điện dung này để suy ra lực gia tốc ($F=ma$).
*   **Lưu ý:** Nó đo cả gia tốc trọng trường ($g \approx 9.8 m/s^2$). Khi điện thoại nằm yên trên bàn, gia tốc kế vẫn báo $Z \approx 9.8$.

### 2. Gyroscope (Con quay hồi chuyển) - Đo tốc độ quay
*   **Nguyên lý:** Hoạt động dựa trên **Lực Coriolis**.
    *   Trong chip MEMS có một vật thể rung liên tục.
    *   Khi bạn xoay điện thoại, lực Coriolis sẽ làm vật thể này bị lệch hướng rung.
    *   Cảm biến đo độ lệch này để tính ra tốc độ góc (Angular Velocity) theo trục X, Y, Z.
*   **Ứng dụng:** Giúp xác định hướng xoay chính xác hơn Accelerometer rất nhiều (dùng trong game ổn định, VR 360 độ).

### 3. Magnetometer (Từ kế) - Chiếc la bàn số
*   **Nguyên lý:** Sử dụng **Hiệu ứng Hall** (Hall Effect).
    *   Khi dòng điện chạy qua một tấm dẫn điện đặt trong từ trường, các electron bị lệch về một phía tạo ra hiệu điện thế.
    *   Cảm biến đo hiệu điện thế này để xác định cường độ và hướng của từ trường Trái đất.
*   **Điểm yếu:** Rất dễ bị nhiễu bởi kim loại (sắt thép) hoặc nam châm trong ốp lưng điện thoại.

---

## 20.2. Điều kiện Cần và Đủ để lập trình Cảm biến

Khác với lập trình UI thông thường, làm việc với Hardware yêu cầu môi trường thực tế và cấp quyền nghiêm ngặt.

### 1. Phần cứng (Hardware) - Điều kiện Cần
*   **Thiết bị thật (Real Device):**
    *   Hầu hết máy ảo (Android Emulator / iOS Simulator) **KHÔNG** mô phỏng được cảm biến chính xác hoặc rất hạn chế (chỉ chỉnh tay được vài thông số giả lập).
    *   **Bắt buộc:** Phải có thiết bị thật để test độ mượt và độ chính xác (đặc biệt là La bàn và Đếm bước).
*   **Kiểm tra tính khả dụng:** Không phải điện thoại nào cũng có đủ cảm biến (ví dụ: máy giá rẻ có thể không có Gyroscope hoặc Barometer).

### 2. Cấp quyền (Permissions) - Điều kiện Đủ
Hệ điều hành (OS) chặn truy cập cảm biến để bảo vệ riêng tư. Bạn phải khai báo và xin quyền.

*   **Android (`AndroidManifest.xml`):**
    *   Vị trí: `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
    *   Đếm bước (Android 10+): `<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />`
    *   Khai báo phần cứng (Optional nhưng tốt cho Google Play): `<uses-feature android:name="android.hardware.sensor.accelerometer" android:required="true" />`
*   **iOS (`Info.plist`):**
    *   Vị trí: `NSLocationWhenInUseUsageDescription`.
    *   Motion: `NSMotionUsageDescription` (Sử dụng dữ liệu chuyển động).

### 3. Thư viện (Package)
Sử dụng các plugin cầu nối (Bridge) để Dart giao tiếp với Native API (SensorManager của Android / CoreMotion của iOS).
*   `sensors_plus`: Phổ biến nhất cho Motion/Orientation.
*   `geolocator`: Chuẩn mực cho GPS.

---

## 20.3. Cài đặt Dependencies

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sensors_plus: ^6.1.0 
  geolocator: ^13.0.0
  light_sensor: ^0.0.1 
  permission_handler: ^11.3.1
```

*(Các phần thực hành bên dưới giữ nguyên logic code nhưng sinh viên cần chú ý đọc kỹ các giải thích về luồng dữ liệu)*

---

## 20.4. Thực hành 1: Máy Đo Chuyển Động (Motion Tracker)

**Nhiệm vụ:** Xây dựng ứng dụng đếm số lần "Nhảy" (Jump) hoặc "Lắc mạnh" (Shake) dựa trên gia tốc kế người dùng (`UserAccelerometer`).

### Nguyên lý ứng dụng
*   Sử dụng `UserAccelerometer` để **loại bỏ trọng lực**. Nếu dùng `Accelerometer` thường, bạn phải tự trừ đi 9.8 m/s² (rất phức tạp vì hướng trọng lực thay đổi khi xoay máy).
*   Phát hiện đỉnh (Peak Detection): Khi gia tốc vượt ngưỡng (Threshold), ghi nhận sự kiện.

### Triển khai Code (`motion_tracker.dart`)

```dart
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
```

### 📸 Yêu cầu Báo cáo Thực tế (Report Requirement)
1.  **Hành động:** Cầm điện thoại trên tay, thực hiện động tác nhảy tại chỗ hoặc lắc tay mạnh 10 lần.
2.  **Minh chứng:**
    *   Chụp ảnh màn hình ứng dụng hiển thị số `SHAKE COUNT` > 10.
    *   Chụp 1 bức ảnh bạn đang cầm điện thoại thực hiện động tác (nhờ bạn bè chụp hoặc selfie gương).

---

## 20.5. Thực hành 2: Nhà Thám Hiểm (GPS + La Bàn)

**Nhiệm vụ:** Kết hợp `Geolocator` (Vị trí) và `Magnetometer` (Hướng) để tạo công cụ sinh tồn.

### Nguyên lý ứng dụng
*   **GPS:** Tính toán khoảng cách thời gian tín hiệu từ ít nhất 4 vệ tinh quay quanh Trái đất để suy ra toạ độ (Phép đạc tam giác).
*   **La bàn:** Đọc từ trường cực Bắc của Trái đất.

### 1. Cấu hình quyền (Permission)
**Android (`AndroidManifest.xml`):**
```xml
<!-- Quyền chính xác (Fine Location) dùng GPS -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<!-- Quyền tương đối (Coarse Location) dùng Wifi/Cell tower -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 2. Triển khai Code (`explorer_tool.dart`)

```dart
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

    // 3. Lấy tọa độ hiện tại (High Accuracy dùng GPS)
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _locationMessage = 
          "Vĩ độ (Lat): ${position.latitude}\nKinh độ (Long): ${position.longitude}\nĐộ cao (Alt): ${position.altitude.toStringAsFixed(1)}m";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Explorer Tool"), backgroundColor: Colors.grey[900]),
      body: Column(
        children: [
          // Phần 1: Hiển thị GPS
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.blueGrey[900],
            child: Text(
              _locationMessage,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Phần 2: La bàn (Magnetometer)
          Expanded(
            child: StreamBuilder<MagnetometerEvent>(
              stream: magnetometerEventStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final event = snapshot.data!;
                // Tính góc hướng bắc (Azimuth) dùng hàm atan2
                double heading = atan2(event.y, event.x); // Kết quả là Radian
                
                // Chuyển sang độ
                double headingDegrees = heading * 180 / pi; 
                if (headingDegrees < 0) headingDegrees += 360;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${headingDegrees.toStringAsFixed(0)}°", 
                        style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
                      const Text("HƯỚNG BẮC", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),
                      // Transform.rotate nhận vào Radian
                      Transform.rotate(
                        angle: -heading, // Xoay ngược chiều kim đồng hồ để bù lại góc xoay của điện thoại
                        child: const Icon(Icons.navigation, size: 150, color: Colors.redAccent),
                      ),
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
}
```

### 📸 Yêu cầu Báo cáo Thực tế
1.  **Hành động:** Đi ra ngoài trời (sân trường, công viên, hoặc trước cửa nhà). Không ngồi trong phòng kín (GPS sẽ kém chính xác hoặc mất sóng).
2.  **Minh chứng:**
    *   Chụp ảnh màn hình ứng dụng hiển thị rõ **Tọa độ GPS** và **La bàn đang hoạt động**.
    *   Chụp 1 bức ảnh khung cảnh nơi bạn đứng (check-in) để chứng minh bạn đang ở ngoài trời.

---

## 20.6. Thực hành 3: Cảm biến Ánh sáng (Light Sensor)

**Nhiệm vụ:** Đo cường độ sáng nơi bạn ở để làm đèn ngủ tự động.

### Nguyên lý ứng dụng
*   Photodiode (Đi-ốt quang) trên mặt trước điện thoại chuyển đổi photon ánh sáng thành dòng điện. Dòng điện càng lớn -> ánh sáng càng mạnh (đơn vị Lux).

### Triển khai Code (`light_meter.dart`)
Sử dụng package `light_sensor`.

```dart
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
            Icon(Icons.lightbulb, 
                size: 100, 
                color: isDark ? Colors.grey : Colors.orangeAccent),
            const SizedBox(height: 20),
            Text(
              "$_luxValue LUX",
              style: TextStyle(
                  fontSize: 60, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black),
            ),
            Text(
              getLightStatus(_luxValue),
              style: TextStyle(
                  fontSize: 24, 
                  color: isDark ? Colors.white70 : Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
```

### 📸 Yêu cầu Báo cáo Thực tế
1.  **Hành động 1 (Trong tối):** Tắt đèn phòng hoặc lấy tay che cảm biến (thường ở mép trên điện thoại). Chụp màn hình khi chỉ số LUX thấp.
2.  **Hành động 2 (Ngoài sáng):** Bật đèn hoặc ra ngoài trời. Chụp màn hình khi chỉ số LUX cao.
3.  **Minh chứng:** Ghép 2 ảnh trên vào báo cáo. Chụp thêm 1 ảnh bóng đèn/mặt trời tại nơi bạn đo.

---

## 20.7. Tổng kết Bài tập lớn

Sinh viên nộp file báo cáo (PDF/Word) gồm:

1.  **Mã nguồn:** Link GitHub dự án chứa cả 3 chức năng trên.
2.  **Báo cáo hình ảnh (QUAN TRỌNG):**
    *   Trang 1: Ảnh chụp màn hình phần **Motion Tracker** + Ảnh bạn đang cầm máy lắc/nhảy.
    *   Trang 2: Ảnh chụp màn hình phần **Explorer Tool** (hiện GPS) + Ảnh check-in ngoài trời tại vị trí đó.
    *   Trang 3: Ảnh chụp màn hình **Light Meter** (Sáng/Tối) + Ảnh nguồn sáng tương ứng.

> **Tư duy:** Những lập trình viên Mobile giỏi là những người hiểu rõ phần cứng họ đang điều khiển. Hãy bước ra ngoài và kiểm chứng code của chính mình!

---
[< Bài trước](19_do_an_nang_cao.md) | [Bài tiếp theo >](21_firebase_studio.md)
