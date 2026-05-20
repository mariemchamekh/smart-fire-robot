import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/firebase_robot_service.dart';
import '../theme/app_colors.dart';
import 'robot_control_screen.dart';

class RobotMapScreen extends StatefulWidget {
  const RobotMapScreen({super.key});

  @override
  State<RobotMapScreen> createState() => _RobotMapScreenState();
}

class _RobotMapScreenState extends State<RobotMapScreen> {
  final MapController _mapCtrl = MapController();

  LatLng _robotPos = const LatLng(34.75, 10.76); // Position par défaut (Tunis)
  bool _firebaseConnected = false;

  StreamSubscription? _connSub;
  // StreamSubscription? _posSub;   // Supprimé car non disponible pour le moment

  @override
  void initState() {
    super.initState();

    firebaseRobotService.isConnected.then((connected) {
      if (mounted) {
        setState(() => _firebaseConnected = connected);
      }
    });

    // Écoute uniquement la connexion Firebase
    _connSub = firebaseRobotService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() => _firebaseConnected = connected);
      }
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bg : AppColors.bgLight;
    final textColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Robot — Position Live"),
        actions: [
          // Badge connexion Firebase
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (_firebaseConnected ? AppColors.green : AppColors.subText)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (_firebaseConnected ? AppColors.green : AppColors.subText)
                    .withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _firebaseConnected ? AppColors.green : AppColors.subText,
                  size: 8,
                ),
                const SizedBox(width: 5),
                Text(
                  _firebaseConnected ? "LIVE" : "DÉMO",
                  style: TextStyle(
                    color: _firebaseConnected ? AppColors.green : AppColors.subText,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Bouton commande
          IconButton(
            icon: const Icon(Icons.gamepad_rounded, color: AppColors.orange),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RobotControlScreen())),
            tooltip: "Contrôler le robot",
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _robotPos,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.smart_fire_robot",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _robotPos,
                    width: 52,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.redAlert.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.redAlert, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.redAlert.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.redAlert,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Overlay coordonnées
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
                    "Lat: ${_robotPos.latitude.toStringAsFixed(5)}",
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    "Lng: ${_robotPos.longitude.toStringAsFixed(5)}",
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          // Bouton flottant contrôle
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RobotControlScreen())),
              backgroundColor: AppColors.red,
              icon: const Icon(Icons.gamepad_rounded, color: Colors.white),
              label: const Text(
                "Contrôler",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}