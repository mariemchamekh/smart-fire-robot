import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_robot_service.dart';
import '../theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _firebaseConnected = false;
  StreamSubscription? _connSub;

  @override
  void initState() {
    super.initState();

    firebaseRobotService.isConnected.then((connected) {
      if (mounted) setState(() => _firebaseConnected = connected);
    });

    _connSub = firebaseRobotService.connectionStream.listen((connected) {
      if (mounted) setState(() => _firebaseConnected = connected);
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
    final bg = isDark ? AppColors.bg : AppColors.bgLight;
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<RobotLiveData>(
        stream: firebaseRobotService.liveDataStream,
        builder: (context, snapshot) {
          final data = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _header(cardColor),

                const SizedBox(height: 16),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),

                if (data == null)
                  _tile(
                    context,
                    "Firebase Data",
                    "No Data",
                    Icons.warning_amber_rounded,
                    AppColors.redAlert,
                    cardColor,
                  )
                else ...[
                  _tile(
                    context,
                    "Température",
                    "${data.temperature.toStringAsFixed(1)} °C",
                    Icons.thermostat_rounded,
                    AppColors.orange,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Gas Level",
                    "${data.gas}",
                    Icons.cloud_rounded,
                    data.gas > 600 ? AppColors.redAlert : AppColors.orange,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Flamme",
                    data.flame ? "Détectée" : "Non",
                    Icons.local_fire_department_rounded,
                    data.flame ? AppColors.redAlert : AppColors.green,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Distance",
                    "${data.distance.toStringAsFixed(1)} cm",
                    Icons.social_distance_rounded,
                    AppColors.orange,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Fire AI",
                    data.fire ? "FIRE DETECTED" : "No Fire",
                    Icons.visibility_rounded,
                    data.fire ? AppColors.redAlert : AppColors.green,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Fire Color",
                    data.fireColor.toUpperCase(),
                    Icons.palette_rounded,
                    AppColors.orange,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Urgency",
                    "${data.urgency}%",
                    Icons.priority_high_rounded,
                    data.urgency > 70 ? AppColors.redAlert : AppColors.orange,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Confidence",
                    "${data.confidence}%",
                    Icons.verified_rounded,
                    AppColors.green,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Probable Cause",
                    data.cause,
                    Icons.info_outline_rounded,
                    AppColors.orange,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Robot Mode",
                    data.mode,
                    Icons.smart_toy_outlined,
                    AppColors.green,
                    cardColor,
                  ),
                  const SizedBox(height: 12),

                  _tile(
                    context,
                    "Robot Status",
                    data.status,
                    Icons.wifi_tethering_rounded,
                    data.status == "ONLINE" ? AppColors.green : AppColors.redAlert,
                    cardColor,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.red, Color(0xFF2A1615)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: AppColors.orange, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "System Status",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            _firebaseConnected ? "● LIVE" : "● OFFLINE",
            style: TextStyle(
              color: _firebaseConnected ? AppColors.green : Colors.white60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color c,
      Color cardColor,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.text : AppColors.textLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 25),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textColor,
                fontSize: 15,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}