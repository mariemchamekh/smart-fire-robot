import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/app_navbar.dart';
import 'main_shell.dart';
import 'admin_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bg : AppColors.bgLight;
    final textColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return Scaffold(
      body: Stack(
        children: [
          // Background image firetree
          const Positioned.fill(
            child: Image(
              image: AssetImage("assets/images/firetree.jpg"),
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.28),
            ),
          ),
          // Gradient overlay adaptatif
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    bgColor.withOpacity(0.97),
                    bgColor.withOpacity(0.85),
                    bgColor.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.45, 0.75, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar : logo + toggle
                  Row(
                    children: [
                      // Logo adaptatif (black bg en dark, white bg en light)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          isDark
                              ? 'assets/images/logoblackbg.jpeg'
                              : 'assets/images/logowhitebg.jpeg',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Smart Fire & Security Robot",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      // Theme toggle button
                      const ThemeToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Choisir\nun accès",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Interface Dark • Alertes • Map Live",
                    style: TextStyle(color: subColor, fontSize: 13),
                  ),
                  const Spacer(),
                  _bigBtn(
                    context,
                    isDark: isDark,
                    icon: Icons.person_outline_rounded,
                    title: "User Access",
                    subtitle: "Dashboard + Map + Camera",
                    onTap: () {
                      navNotifier.goTo(NavTab.home);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MainShell()));
                    },
                  ),
                  const SizedBox(height: 12),
                  _bigBtn(
                    context,
                    isDark: isDark,
                    icon: Icons.admin_panel_settings_outlined,
                    title: "Admin Access",
                    subtitle: "Monitoring + Alertes",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
                  ),
                  const SizedBox(height: 12),
                  _bigBtn(
                    context,
                    isDark: isDark,
                    icon: Icons.warning_rounded,
                    title: "Emergency Access",
                    subtitle: "Fire Alert + Actions",
                    onTap: () {
                      navNotifier.goTo(NavTab.alert);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MainShell()));
                    },
                    danger: true,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigBtn(
      BuildContext context, {
        required bool isDark,
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool danger = false,
      }) {
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;
    final card2Color = isDark ? AppColors.card2 : AppColors.card2Light;
    final titleColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: danger
                ? [AppColors.redAlert.withOpacity(0.9), AppColors.orange.withOpacity(0.7)]
                : [cardColor.withOpacity(0.95), card2Color.withOpacity(0.9)],
          ),
          border: Border.all(
            color: danger ? AppColors.redAlert.withOpacity(0.7) : AppColors.red.withOpacity(0.25),
          ),
          boxShadow: danger
              ? [BoxShadow(color: AppColors.redAlert.withOpacity(0.22), blurRadius: 14, offset: const Offset(0, 4))]
              : [BoxShadow(color: AppColors.red.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: danger ? Colors.white.withOpacity(0.2) : AppColors.red.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: danger ? Colors.white : AppColors.redAlert,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: danger ? Colors.white : titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: danger ? Colors.white70 : subColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: danger ? Colors.white54 : AppColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}