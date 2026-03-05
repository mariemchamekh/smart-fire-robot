import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: const [ThemeToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [AppColors.red, Color(0xFF2A1615)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.red.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, color: AppColors.orange, size: 28),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "System Status",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    Text(
                      "Live sensor data",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tile(context, "Température", "45°C", Icons.thermostat_rounded, AppColors.orange, cardColor),
          const SizedBox(height: 12),
          _tile(context, "Smoke Level", "High", Icons.cloud_rounded, AppColors.redAlert, cardColor),
          const SizedBox(height: 12),
          _tile(context, "Fire Detection", "Detected", Icons.local_fire_department_rounded, AppColors.redAlert, cardColor),
          const SizedBox(height: 12),
          _tile(context, "Robot Status", "Active", Icons.smart_toy_outlined, AppColors.green, cardColor),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String title, String value, IconData icon, Color c, Color cardColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.text : AppColors.textLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: c.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withOpacity(0.4)),
            ),
            child: Text(value, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}