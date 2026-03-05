import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/app_drawer.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_colors.dart';

class RobotMapScreen extends StatefulWidget {
  const RobotMapScreen({super.key});

  @override
  State<RobotMapScreen> createState() => _RobotMapScreenState();
}

class _RobotMapScreenState extends State<RobotMapScreen> {
  final MapController _controller = MapController();
  LatLng robotPos = const LatLng(34.75, 10.76);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        robotPos = LatLng(robotPos.latitude + 0.001, robotPos.longitude + 0.001);
      });
      _controller.move(robotPos, _controller.camera.zoom);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bg : AppColors.bgLight;
    final textColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Robot — Position Live"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.circle, color: AppColors.green, size: 8),
                SizedBox(width: 5),
                Text("LIVE",
                    style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(initialCenter: robotPos, initialZoom: 9),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.smart_fire_robot",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: robotPos,
                    width: 52,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.redAlert.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.redAlert, width: 2.5),
                        boxShadow: [BoxShadow(color: AppColors.redAlert.withOpacity(0.3), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.smart_toy_rounded, color: AppColors.redAlert, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Coordinates overlay
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Position Robot", style: TextStyle(color: subColor, fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(
                    "Lat: ${robotPos.latitude.toStringAsFixed(4)}",
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    "Lng: ${robotPos.longitude.toStringAsFixed(4)}",
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}