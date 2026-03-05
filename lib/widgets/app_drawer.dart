import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/theme_toggle_button.dart';
import '../screens/user_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/robot_map_screen.dart';
import '../screens/camera_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.bg2 : AppColors.bg2Light,
      child: SafeArea(
        child: Column(
          children: [
            _header(context, isDark),
            const SizedBox(height: 8),
            // Theme toggle dans le drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Apparence",
                    style: TextStyle(
                      color: isDark ? AppColors.subText : AppColors.subTextLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const ThemeToggleButton(),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 4),
            _item(context, Icons.person_outline_rounded, "User Dashboard", const UserScreen(), isDark),
            _item(context, Icons.admin_panel_settings_outlined, "Admin Dashboard", const AdminScreen(), isDark),
            _item(context, Icons.warning_rounded, "Emergency", const EmergencyScreen(), isDark, danger: true),
            _item(context, Icons.map_rounded, "Robot Map (Live)", const RobotMapScreen(), isDark),
            _item(context, Icons.videocam_rounded, "Live Camera", const CameraScreen(), isDark),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.card : AppColors.cardLight).withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const AppLogo(size: 28, variant: LogoVariant.transparent),
                  const SizedBox(width: 10),
                  Text(
                    "Smart Fire & Security Robot",
                    style: TextStyle(
                      color: isDark ? AppColors.subText : AppColors.subTextLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // firetree2.jpg dans le header drawer
          image: AssetImage("assets/images/firetree2.jpg"),
          fit: BoxFit.cover,
          opacity: 0.45,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isDark ? AppColors.bg2 : AppColors.bg2Light).withOpacity(0.9),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo dans le header du drawer
            const AppLogo(size: 44, variant: LogoVariant.transparent),
            const SizedBox(height: 8),
            const Text(
              "Menu",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, Widget page,
      bool isDark, {bool danger = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: danger ? AppColors.redAlert : AppColors.orange.withOpacity(0.8),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: danger
              ? AppColors.redAlert
              : (isDark ? AppColors.text : AppColors.textLight),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}