import 'dart:async';
import 'package:latlong2/latlong.dart';

class MqttService {
  final _ctrl = StreamController<LatLng>.broadcast();
  Stream<LatLng> get positionStream => _ctrl.stream;

  Timer? _timer;
  LatLng _pos = const LatLng(34.0, 10.0);

  // ✅ الآن: Demo بدون broker
  void connectDemo() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      // حركة بسيطة
      _pos = LatLng(_pos.latitude + 0.002, _pos.longitude + 0.002);
      _ctrl.add(_pos);
    });
  }

  // 🔜 بعد ما تربطي الروبوت: نبدل connectDemo بـ connectMqtt(...)
  // (نعطيك النسخة MQTT وقتها بالتفصيل)
  void disconnect() {
    _timer?.cancel();
  }
}