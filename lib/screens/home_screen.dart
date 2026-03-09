import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_navbar.dart';
import 'admin_screen.dart';
import 'camera_screen.dart';

/// Contenu de l'onglet Home.
/// Le Scaffold et la navbar sont gérés par MainShell.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    if (user == null) return const SizedBox.shrink();
    return user.isAdmin ? _AdminHome(user: user) : _OwnerHome(user: user);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME ADMIN
// ─────────────────────────────────────────────────────────────────────────────
class _AdminHome extends StatelessWidget {
  final AppUser user;
  const _AdminHome({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppColors.bg      : AppColors.bgLight;
    final textColor = isDark ? AppColors.text    : AppColors.textLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;
    final cardColor = isDark ? AppColors.card    : AppColors.cardLight;

    return Stack(
      children: [
        // Background firetree2 sur tout l'écran
        const Positioned.fill(
          child: Image(
            image: AssetImage("assets/images/firetree2.jpg"),
            fit: BoxFit.cover,
            opacity: AlwaysStoppedAnimation(0.22),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgColor.withOpacity(0.97),
                  bgColor.withOpacity(0.80),
                  bgColor.withOpacity(0.4),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Contenu
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _welcomeBanner(user, isDark),
              const SizedBox(height: 14),
              _roleBadge(user, cardColor),
              const SizedBox(height: 20),
              _sectionLabel("ACCÈS COMPLET", subColor),
              const SizedBox(height: 10),
              _navCard(
                context, isDark: isDark,
                title: "Admin Dashboard",
                subtitle: "Capteurs, températures, alertes",
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.orange,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminScreen())),
              ),
              const SizedBox(height: 10),
              _navCard(
                context, isDark: isDark,
                title: "Live Camera",
                subtitle: "Flux vidéo du robot",
                icon: Icons.videocam_rounded,
                color: AppColors.red,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CameraScreen())),
              ),
              const SizedBox(height: 10),
              _navCard(
                context, isDark: isDark,
                title: "Emergency Alert",
                subtitle: "Gérer les alertes incendie",
                icon: Icons.warning_rounded,
                color: AppColors.redAlert,
                danger: true,
                onTap: () {
                  navNotifier.goTo(NavTab.alert);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME OWNER
// ─────────────────────────────────────────────────────────────────────────────
class _OwnerHome extends StatelessWidget {
  final AppUser user;
  const _OwnerHome({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppColors.bg      : AppColors.bgLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;
    final cardColor = isDark ? AppColors.card    : AppColors.cardLight;

    return Stack(
      children: [
        // Background firetree2 sur tout l'écran
        const Positioned.fill(
          child: Image(
            image: AssetImage("assets/images/firetree2.jpg"),
            fit: BoxFit.cover,
            opacity: AlwaysStoppedAnimation(0.22),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgColor.withOpacity(0.97),
                  bgColor.withOpacity(0.80),
                  bgColor.withOpacity(0.4),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Contenu
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _welcomeBanner(user, isDark),
              const SizedBox(height: 14),
              _roleBadge(user, cardColor),
              const SizedBox(height: 20),
              _sectionLabel("NAVIGATION RAPIDE", subColor),
              const SizedBox(height: 10),
              _navCard(
                context, isDark: isDark,
                title: "Live Camera",
                subtitle: "Flux vidéo du robot",
                icon: Icons.videocam_rounded,
                color: AppColors.red,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CameraScreen())),
              ),
              const SizedBox(height: 10),
              _navCard(
                context, isDark: isDark,
                title: "Emergency Alert",
                subtitle: "Voir les alertes actives",
                icon: Icons.warning_rounded,
                color: AppColors.redAlert,
                danger: true,
                onTap: () => navNotifier.goTo(NavTab.alert),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PARTAGÉS
// ─────────────────────────────────────────────────────────────────────────────
Widget _sectionLabel(String text, Color color) => Align(
  alignment: Alignment.centerLeft,
  child: Text(
    text,
    style: TextStyle(
      color: color, fontSize: 11,
      fontWeight: FontWeight.w700, letterSpacing: 1.4,
    ),
  ),
);

Widget _welcomeBanner(AppUser user, bool isDark) {
  final bgColor = isDark ? AppColors.bg : AppColors.bgLight;

  return Container(
    width: double.infinity,
    height: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      image: const DecorationImage(
        image: AssetImage("assets/images/firetree2.jpg"),
        fit: BoxFit.cover,
        opacity: 0.5,
      ),
      border: Border.all(color: AppColors.red.withOpacity(0.3)),
      boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.15), blurRadius: 16)],
    ),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [bgColor.withOpacity(0.88), Colors.transparent],
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
              fontSize: 22, fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.roleLabel,
            style: const TextStyle(
              color: AppColors.orange, fontWeight: FontWeight.w700, fontSize: 14,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _roleBadge(AppUser user, Color cardColor) {
  final color = user.isAdmin ? AppColors.orange : AppColors.green;
  final icon  = user.isAdmin ? Icons.admin_panel_settings_outlined : Icons.forest_rounded;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(user.roleLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(width: 8),
        Text("• ${user.email}",
            style: TextStyle(color: color.withOpacity(0.6), fontSize: 12)),
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
  final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: danger ? AppColors.redAlert.withOpacity(0.07) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger ? AppColors.redAlert.withOpacity(0.3) : color.withOpacity(0.18),
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
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 15)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: subColor, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14,
              color: isDark ? AppColors.iconSecondary : AppColors.iconSecLight),
        ],
      ),
    ),
  );
}