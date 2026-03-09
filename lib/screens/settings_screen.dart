import 'package:flutter/material.dart';
import '../services/theme_notifier.dart';
import '../theme/app_colors.dart';
import '../widgets/app_navbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🔜 Ces valeurs seront liées aux préférences persistantes plus tard
  bool _notifFire    = true;
  bool _notifHuman   = true;
  bool _notifAnimal  = true;
  bool _soundAlert   = true;
  bool _vibration    = true;
  bool _autoRefresh  = true;
  double _refreshInterval = 2.0; // secondes

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card  : AppColors.cardLight;
    final textColor = isDark ? AppColors.text  : AppColors.textLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Apparence ────────────────────────────────────
          _sectionTitle("Apparence", Icons.palette_outlined, textColor),
          const SizedBox(height: 8),
          _card(cardColor, [
            _switchTile(
              icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              iconColor: AppColors.orange,
              label: "Mode sombre",
              value: isDark,
              textColor: textColor,
              subColor: subColor,
              onChanged: (_) => themeNotifier.toggle(),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Notifications ─────────────────────────────────
          _sectionTitle("Notifications", Icons.notifications_outlined, textColor),
          const SizedBox(height: 8),
          _card(cardColor, [
            _switchTile(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.redAlert,
              label: "Alerte incendie",
              sublabel: "Notifier en cas de feu détecté",
              value: _notifFire,
              textColor: textColor,
              subColor: subColor,
              onChanged: (v) => setState(() => _notifFire = v),
            ),
            _divider(subColor),
            _switchTile(
              icon: Icons.person_rounded,
              iconColor: AppColors.redAlert,
              label: "Détection humaine",
              sublabel: "Priorité maximale",
              value: _notifHuman,
              textColor: textColor,
              subColor: subColor,
              onChanged: (v) => setState(() => _notifHuman = v),
            ),
            _divider(subColor),
            _switchTile(
              icon: Icons.pets_rounded,
              iconColor: AppColors.orange,
              label: "Détection animale",
              sublabel: "Alerte faune",
              value: _notifAnimal,
              textColor: textColor,
              subColor: subColor,
              onChanged: (v) => setState(() => _notifAnimal = v),
            ),
            _divider(subColor),
            _switchTile(
              icon: Icons.volume_up_rounded,
              iconColor: AppColors.orange,
              label: "Son d'alerte",
              value: _soundAlert,
              textColor: textColor,
              subColor: subColor,
              onChanged: (v) => setState(() => _soundAlert = v),
            ),
            _divider(subColor),
            _switchTile(
              icon: Icons.vibration_rounded,
              iconColor: AppColors.iconSecondary,
              label: "Vibration",
              value: _vibration,
              textColor: textColor,
              subColor: subColor,
              onChanged: (v) => setState(() => _vibration = v),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Robot & Capteurs ──────────────────────────────
          _sectionTitle("Robot & Capteurs", Icons.smart_toy_outlined, textColor),
          const SizedBox(height: 8),
          _card(cardColor, [
            _switchTile(
              icon: Icons.refresh_rounded,
              iconColor: AppColors.green,
              label: "Actualisation auto",
              sublabel: "Position GPS en temps réel",
              value: _autoRefresh,
              textColor: textColor,
              subColor: subColor,
              onChanged: (v) => setState(() => _autoRefresh = v),
            ),
            if (_autoRefresh) ...[
              _divider(subColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_rounded,
                            color: AppColors.green, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Intervalle de mise à jour",
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${_refreshInterval.toStringAsFixed(0)}s",
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _refreshInterval,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.green,
                      inactiveColor: AppColors.green.withOpacity(0.2),
                      onChanged: (v) =>
                          setState(() => _refreshInterval = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("1s (temps réel)",
                            style: TextStyle(
                                color: subColor, fontSize: 10)),
                        Text("10s",
                            style: TextStyle(
                                color: subColor, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ]),

          const SizedBox(height: 16),

          // ── À propos ──────────────────────────────────────
          _sectionTitle("À propos", Icons.info_outline_rounded, textColor),
          const SizedBox(height: 8),
          _card(cardColor, [
            _infoTile(Icons.rocket_launch_outlined, "Version", "1.0.0",
                textColor, subColor),
            _divider(subColor),
            _infoTile(Icons.local_fire_department_rounded, "Projet",
                "Smart Fire Robot", textColor, subColor),
            _divider(subColor),
            _infoTile(Icons.code_rounded, "Stack",
                "Flutter + Firebase", textColor, subColor),
            _divider(subColor),
            // 🔜 MQTT broker info
            _infoTile(Icons.sensors_rounded, "MQTT",
                "Non connecté (bientôt)", textColor, subColor),
          ]),

          const SizedBox(height: 20),

          // ── Reset compteur alertes (démo) ─────────────────
          Center(
            child: TextButton.icon(
              onPressed: () {
                navNotifier.setAlertCount(0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Alertes réinitialisées"),
                    backgroundColor: AppColors.card,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_off_outlined,
                  color: AppColors.subText, size: 18),
              label: Text(
                "Marquer toutes les alertes comme lues",
                style: TextStyle(color: subColor, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: AppColors.orange, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _card(Color cardColor, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withOpacity(0.12)),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? sublabel,
    required bool value,
    required Color textColor,
    required Color subColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                if (sublabel != null)
                  Text(sublabel,
                      style: TextStyle(color: subColor, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.orange,
            activeTrackColor: AppColors.orange.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value,
      Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: subColor, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _divider(Color subColor) =>
      Divider(height: 1, color: subColor.withOpacity(0.1));
}