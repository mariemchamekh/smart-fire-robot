import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/app_navbar.dart';
import '../screens/admin_screen.dart';
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
            // ── Partie scrollable (header + items) ──
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
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
                  // Items qui switchent vers un onglet du MainShell
                  _navItem(context, Icons.home_rounded, "Accueil", NavTab.home, isDark),
                  _navItem(context, Icons.map_rounded, "Robot Map (Live)", NavTab.map, isDark),
                  _navItem(context, Icons.warning_rounded, "Emergency", NavTab.alert, isDark, danger: true),
                  _navItem(context, Icons.person_rounded, "Profil", NavTab.profile, isDark),
                  _navItem(context, Icons.settings_rounded, "Paramètres", NavTab.settings, isDark),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 4),
                  // Items qui ouvrent une page séparée (avec leur propre Scaffold)
                  _pushItem(context, Icons.admin_panel_settings_outlined, "Admin Dashboard", const AdminScreen(), isDark),
                  _pushItem(context, Icons.videocam_rounded, "Live Camera", const CameraScreen(), isDark),
                ],
              ),
            ),
            // ── Footer toujours visible en bas ──
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
                  Flexible(
                    child: Text(
                      "Smart Fire & Security Robot",
                      style: TextStyle(
                        color: isDark ? AppColors.subText : AppColors.subTextLight,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  /// Item qui switch vers un onglet du MainShell
  Widget _navItem(BuildContext context, IconData icon, String title,
      NavTab tab, bool isDark, {bool danger = false}) {
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
        Navigator.pop(context); // Fermer le drawer
        navNotifier.goTo(tab);  // Basculer vers l'onglet
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  /// Item qui push une page séparée (avec son propre Scaffold)
  Widget _pushItem(BuildContext context, IconData icon, String title,
      Widget page, bool isDark) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.orange.withOpacity(0.8),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.text : AppColors.textLight,
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
