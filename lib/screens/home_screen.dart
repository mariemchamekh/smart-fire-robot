import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_model.dart';
import '../services/theme_notifier.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_colors.dart';
import 'admin_screen.dart';
import 'user_screen.dart';
import 'emergency_screen.dart';
import 'robot_map_screen.dart';
import 'camera_screen.dart';
import 'login_screen.dart';

/// Écran d'accueil après connexion.
/// Redirige et affiche les fonctionnalités selon le rôle.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    // Sécurité : si pas connecté, retour au login
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return user.isAdmin ? _AdminHome(user: user) : _OwnerHome(user: user);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME ADMIN — accès complet
// ─────────────────────────────────────────────────────────────────────────────
class _AdminHome extends StatelessWidget {
  final AppUser user;
  const _AdminHome({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, isDark, textColor),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeBanner(user, isDark, textColor, subColor),
          const SizedBox(height: 16),
          // Badge rôle admin
          _roleBadge(user, cardColor),
          const SizedBox(height: 20),
          Text(
            "ACCÈS COMPLET",
            style: TextStyle(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          _navCard(
            context,
            isDark: isDark,
            title: "Admin Dashboard",
            subtitle: "Capteurs, températures, alertes",
            icon: Icons.admin_panel_settings_outlined,
            color: AppColors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
          ),
          const SizedBox(height: 10),
          _navCard(
            context,
            isDark: isDark,
            title: "Robot Map (Live)",
            subtitle: "Position GPS en temps réel",
            icon: Icons.map_rounded,
            color: AppColors.redAlert,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RobotMapScreen())),
          ),
          const SizedBox(height: 10),
          _navCard(
            context,
            isDark: isDark,
            title: "Live Camera",
            subtitle: "Flux vidéo du robot",
            icon: Icons.videocam_rounded,
            color: AppColors.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
          ),
          const SizedBox(height: 10),
          _navCard(
            context,
            isDark: isDark,
            title: "Emergency Alert",
            subtitle: "Gérer les alertes incendie",
            icon: Icons.warning_rounded,
            color: AppColors.redAlert,
            danger: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME OWNER — accès limité
// ─────────────────────────────────────────────────────────────────────────────
class _OwnerHome extends StatelessWidget {
  final AppUser user;
  const _OwnerHome({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.text : AppColors.textLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, isDark, textColor),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeBanner(user, isDark, textColor, subColor),
          const SizedBox(height: 16),
          _roleBadge(user, cardColor),
          const SizedBox(height: 20),
          // User dashboard complet
          const UserScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PARTAGÉS
// ─────────────────────────────────────────────────────────────────────────────
AppBar _buildAppBar(BuildContext context, bool isDark, Color textColor) {
  return AppBar(
    title: Row(
      children: const [
        AppLogo(size: 26, variant: LogoVariant.transparent),
        SizedBox(width: 8),
        Text("Smart Fire Robot"),
      ],
    ),
    actions: [
      // Toggle thème
      GestureDetector(
        onTap: () => themeNotifier.toggle(),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.orange.withOpacity(0.3)),
          ),
          child: Icon(
            isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: isDark ? AppColors.orange : AppColors.red,
            size: 18,
          ),
        ),
      ),
      // Logout
      IconButton(
        icon: const Icon(Icons.logout_rounded, size: 20),
        color: AppColors.redAlert,
        onPressed: () {
          authService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
          );
        },
        tooltip: "Se déconnecter",
      ),
    ],
  );
}

Widget _welcomeBanner(AppUser user, bool isDark, Color textColor, Color subColor) {
  return Container(
    height: 160,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      image: const DecorationImage(
        image: AssetImage("assets/images/firetree.jpg"),
        fit: BoxFit.cover,
        opacity: 0.45,
      ),
      border: Border.all(color: AppColors.red.withOpacity(0.3)),
    ),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            (isDark ? AppColors.bg : AppColors.bgLight).withOpacity(0.9),
            Colors.transparent,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Bonjour, ${user.name} 👋",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.roleLabel,
            style: TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _roleBadge(AppUser user, Color cardColor) {
  final isAdmin = user.isAdmin;
  final color = isAdmin ? AppColors.orange : AppColors.green;
  final icon = isAdmin ? Icons.admin_panel_settings_outlined : Icons.forest_rounded;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          user.roleLabel,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          "• ${user.email}",
          style: TextStyle(color: color.withOpacity(0.6), fontSize: 12),
        ),
      ],
    ),
  );
}

Widget _navCard(
    BuildContext context, {
      required bool isDark,
      required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
      bool danger = false,
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
        color: danger ? AppColors.redAlert.withOpacity(0.08) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger ? AppColors.redAlert.withOpacity(0.35) : color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: textColor, fontSize: 15)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(color: subColor, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? AppColors.iconSecondary : AppColors.iconSecLight),
        ],
      ),
    ),
  );
}