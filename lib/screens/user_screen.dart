import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_logo.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_colors.dart';
import 'robot_map_screen.dart';
import 'camera_screen.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: const [
            AppLogo(size: 28, variant: LogoVariant.transparent),
            SizedBox(width: 8),
            Text("User Dashboard"),
          ],
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hero(isDark),
          const SizedBox(height: 16),
          _miniStatusRow(isDark),
          const SizedBox(height: 16),
          Text(
            "NAVIGATION RAPIDE",
            style: TextStyle(
              color: isDark ? AppColors.subText : AppColors.subTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          _card(
            context,
            isDark: isDark,
            title: "Robot Map (Live)",
            subtitle: "Voir la position en temps réel",
            icon: Icons.map_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RobotMapScreen())),
          ),
          const SizedBox(height: 10),
          _card(
            context,
            isDark: isDark,
            title: "Live Camera",
            subtitle: "Flux vidéo du robot",
            icon: Icons.videocam_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
          ),
        ],
      ),
    );
  }

  Widget _hero(bool isDark) {
    final bgColor = isDark ? AppColors.bg : AppColors.bgLight;

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: AssetImage("assets/images/firetree.jpg"),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [bgColor.withOpacity(0.92), bgColor.withOpacity(0.1)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.redAlert.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.redAlert.withOpacity(0.45)),
              ),
              child: const Text(
                "● LIVE",
                style: TextStyle(
                  color: AppColors.redAlert,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Smart Fire Robot\nMonitoring",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
      BuildContext context, {
        required bool isDark,
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;
    final textColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.redAlert, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: subColor, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 15,
                color: isDark ? AppColors.iconSecondary : AppColors.iconSecLight),
          ],
        ),
      ),
    );
  }

  Widget _miniStatusRow(bool isDark) {
    Widget chip(String t, Color c, IconData icon) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 14),
            const SizedBox(width: 6),
            Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ),
    );

    return Row(
      children: [
        chip("Robot: Active", AppColors.green, Icons.smart_toy_outlined),
        const SizedBox(width: 10),
        chip("Smoke: Low", AppColors.yellow, Icons.cloud_outlined),
      ],
    );
  }
}