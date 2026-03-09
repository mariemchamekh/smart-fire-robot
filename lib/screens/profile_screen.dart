import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card  : AppColors.cardLight;
    final textColor = isDark ? AppColors.text  : AppColors.textLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;
    final user      = authService.currentUser;

    if (user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Avatar + info ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.red.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.red.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.red, AppColors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.red.withOpacity(0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    // Logo badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.orange.withOpacity(0.4)),
                        ),
                        child: const AppLogo(
                            size: 22, variant: LogoVariant.transparent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: subColor, fontSize: 13),
                ),
                const SizedBox(height: 12),
                // Badge rôle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: (user.isAdmin ? AppColors.orange : AppColors.green)
                        .withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (user.isAdmin
                          ? AppColors.orange
                          : AppColors.green)
                          .withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.isAdmin
                            ? Icons.admin_panel_settings_outlined
                            : Icons.forest_rounded,
                        color: user.isAdmin
                            ? AppColors.orange
                            : AppColors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.roleLabel,
                        style: TextStyle(
                          color: user.isAdmin
                              ? AppColors.orange
                              : AppColors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Infos compte ─────────────────────────────────
          _section("Informations du compte", cardColor, textColor, [
            _infoTile(Icons.person_outline_rounded, "Nom", user.name,
                textColor, subColor),
            _divider(subColor),
            _infoTile(Icons.email_outlined, "Email", user.email,
                textColor, subColor),
            _divider(subColor),
            _infoTile(
              user.isAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.forest_rounded,
              "Rôle",
              user.roleLabel,
              textColor,
              subColor,
            ),
          ]),

          const SizedBox(height: 14),

          // ── Permissions ───────────────────────────────────
          _section("Accès & Permissions", cardColor, textColor, [
            _permTile("Dashboard Admin", user.isAdmin, textColor, subColor),
            _divider(subColor),
            _permTile("Map Robot Live", true, textColor, subColor),
            _divider(subColor),
            _permTile("Caméra Live", true, textColor, subColor),
            _divider(subColor),
            _permTile("Emergency Alerts", true, textColor, subColor),
          ]),

          const SizedBox(height: 14),

          // ── Bouton logout ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authService.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.redAlert),
              label: const Text(
                "Se déconnecter",
                style: TextStyle(
                    color: AppColors.redAlert, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.redAlert.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _section(String title, Color cardColor, Color textColor,
      List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value,
      Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(color: subColor, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _permTile(
      String label, bool allowed, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: allowed ? AppColors.green : AppColors.subText,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(color: textColor, fontSize: 13)),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: (allowed ? AppColors.green : AppColors.subText)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              allowed ? "Autorisé" : "Refusé",
              style: TextStyle(
                color: allowed ? AppColors.green : AppColors.subText,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color subColor) => Divider(
    height: 1,
    color: subColor.withOpacity(0.12),
  );
}