import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ── Enum détection ────────────────────────────────────────────────────────────
enum DetectionStatus { none, human, animal, both }

// ── Modèle d'une détection ────────────────────────────────────────────────────
class DetectionEvent {
  final DetectionStatus status;
  final String zone;
  final DateTime time;
  final String confidence; // ex: "94%"

  const DetectionEvent({
    required this.status,
    required this.zone,
    required this.time,
    required this.confidence,
  });
}

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  // ── Animations ────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _detectionPulseCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _detectionPulseAnim;

  // ── État de détection (simulé — à remplacer par MQTT/robot) ──
  // 🔜 Ces valeurs viendront du robot via MQTT plus tard
  DetectionStatus _currentDetection = DetectionStatus.both; // <-- démo
  bool _detectionActive = true;

  // Historique des détections simulées
  final List<DetectionEvent> _detectionHistory = [
    DetectionEvent(
      status: DetectionStatus.both,
      zone: "Zone Nord-Est",
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      confidence: "94%",
    ),
    DetectionEvent(
      status: DetectionStatus.human,
      zone: "Zone Centre",
      time: DateTime.now().subtract(const Duration(minutes: 8)),
      confidence: "87%",
    ),
    DetectionEvent(
      status: DetectionStatus.animal,
      zone: "Zone Sud",
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      confidence: "91%",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _detectionPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _detectionPulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _detectionPulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _detectionPulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers détection ─────────────────────────────────────
  Color _detectionColor(DetectionStatus s) {
    switch (s) {
      case DetectionStatus.human:
        return const Color(0xFFFF3B30); // rouge alerte vif
      case DetectionStatus.animal:
        return const Color(0xFFFF9500); // orange
      case DetectionStatus.both:
        return const Color(0xFFFF2D55); // rouge-rose — danger maximum
      case DetectionStatus.none:
        return AppColors.green;
    }
  }

  IconData _detectionIcon(DetectionStatus s) {
    switch (s) {
      case DetectionStatus.human:
        return Icons.person_rounded;
      case DetectionStatus.animal:
        return Icons.pets_rounded;
      case DetectionStatus.both:
        return Icons.warning_rounded;
      case DetectionStatus.none:
        return Icons.check_circle_rounded;
    }
  }

  String _detectionTitle(DetectionStatus s) {
    switch (s) {
      case DetectionStatus.human:
        return "ÊTRE HUMAIN DÉTECTÉ";
      case DetectionStatus.animal:
        return "ANIMAL DÉTECTÉ";
      case DetectionStatus.both:
        return "HUMAIN + ANIMAL DÉTECTÉS";
      case DetectionStatus.none:
        return "AUCUNE DÉTECTION";
    }
  }

  String _detectionSubtitle(DetectionStatus s) {
    switch (s) {
      case DetectionStatus.human:
        return "Personne en danger dans la zone — Évacuation immédiate requise !";
      case DetectionStatus.animal:
        return "Animal détecté dans la zone d'incendie — Alerte faune.";
      case DetectionStatus.both:
        return "Situation critique : personne ET animal détectés — Priorité absolue !";
      case DetectionStatus.none:
        return "Zone surveillée — Aucune présence vivante détectée.";
    }
  }

  String _detectionLabel(DetectionStatus s) {
    switch (s) {
      case DetectionStatus.human:  return "Humain";
      case DetectionStatus.animal: return "Animal";
      case DetectionStatus.both:   return "Humain + Animal";
      case DetectionStatus.none:   return "Rien";
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    return "Il y a ${diff.inHours}h";
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgColor   = isDark ? AppColors.bg    : AppColors.bgLight;
    final cardColor = isDark ? AppColors.card  : AppColors.cardLight;
    final textColor = isDark ? AppColors.text  : AppColors.textLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;
    final detColor  = _detectionColor(_currentDetection);

    // Pas de Scaffold ici — MainShell fournit le Scaffold, AppBar et Navbar
    return Stack(
      children: [
        // Background
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

        // Contenu principal
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 4),

              // ══════════════════════════════════════════════
              // 🔴 BLOC DÉTECTION PRINCIPALE — PRIORITÉ #1
              // ══════════════════════════════════════════════
              _buildDetectionBanner(detColor, cardColor, textColor),

              const SizedBox(height: 14),

              // ── Deux badges détection côte à côte ────────
              if (_currentDetection == DetectionStatus.both)
                _buildDualDetectionBadges(cardColor),

              if (_currentDetection == DetectionStatus.both)
                const SizedBox(height: 14),

              // ── Simulateur de détection (démo) ───────────
              // 🔜 À SUPPRIMER quand le robot sera connecté
              _buildDemoSimulator(cardColor, textColor, subColor),

              const SizedBox(height: 14),

              // ── Capteurs feu ──────────────────────────────
              _buildFireSensors(cardColor, textColor, subColor),

              const SizedBox(height: 14),

              // ── Boutons d'action ──────────────────────────
              _buildActionButtons(cardColor, subColor),

              const SizedBox(height: 14),

              // ── Historique détections ─────────────────────
              _buildDetectionHistory(cardColor, textColor, subColor),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BANNER DÉTECTION PRINCIPALE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDetectionBanner(Color detColor, Color cardColor, Color textColor) {
    final isAlert = _currentDetection != DetectionStatus.none;

    return AnimatedBuilder(
      animation: _detectionPulseAnim,
      builder: (context, child) => Transform.scale(
        scale: isAlert ? _detectionPulseAnim.value : 1.0,
        child: child,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: _currentDetection == DetectionStatus.none
                ? [AppColors.green.withOpacity(0.8), AppColors.green.withOpacity(0.5)]
                : [detColor, detColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: detColor.withOpacity(isAlert ? 0.5 : 0.2),
              blurRadius: isAlert ? 24 : 10,
              spreadRadius: isAlert ? 3 : 0,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icône animée
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _detectionIcon(_currentDetection),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge PRIORITÉ
                      if (_currentDetection != DetectionStatus.none)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "⚠ PRIORITÉ MAXIMALE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      Text(
                        _detectionTitle(_currentDetection),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _detectionSubtitle(_currentDetection),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_currentDetection != DetectionStatus.none) ...[
              const SizedBox(height: 14),
              // Barre de confiance
              Row(
                children: [
                  const Text(
                    "Confiance IA :",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.94,
                        backgroundColor: Colors.white24,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "94%",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoPill(Icons.location_on_rounded, "Zone Nord-Est"),
                  _infoPill(Icons.access_time_rounded, "Il y a 2 min"),
                  _infoPill(Icons.sensors_rounded, "Robot #01"),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BADGES DUAL (humain + animal côte à côte)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDualDetectionBadges(Color cardColor) {
    return Row(
      children: [
        _detectionBadge(
          icon: Icons.person_rounded,
          label: "HUMAIN",
          sublabel: "1 personne détectée",
          color: AppColors.redAlert,
          cardColor: cardColor,
        ),
        const SizedBox(width: 10),
        _detectionBadge(
          icon: Icons.pets_rounded,
          label: "ANIMAL",
          sublabel: "1 animal détecté",
          color: AppColors.orange,
          cardColor: cardColor,
        ),
      ],
    );
  }

  Widget _detectionBadge({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required Color cardColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SIMULATEUR DÉMO (à supprimer quand le robot sera connecté)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDemoSimulator(
      Color cardColor, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border:
                  Border.all(color: AppColors.orange.withOpacity(0.4)),
                ),
                child: const Text(
                  "🔜 DEMO — sera remplacé par le robot",
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Simuler une détection :",
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _simButton(
                DetectionStatus.none,
                "Rien",
                Icons.check_circle_outline_rounded,
                AppColors.green,
              ),
              _simButton(
                DetectionStatus.human,
                "Humain",
                Icons.person_rounded,
                AppColors.redAlert,
              ),
              _simButton(
                DetectionStatus.animal,
                "Animal",
                Icons.pets_rounded,
                AppColors.orange,
              ),
              _simButton(
                DetectionStatus.both,
                "Les deux",
                Icons.warning_rounded,
                const Color(0xFFFF2D55),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simButton(
      DetectionStatus s, String label, IconData icon, Color color) {
    final isActive = _currentDetection == s;
    return GestureDetector(
      onTap: () => setState(() => _currentDetection = s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.18) : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CAPTEURS FEU
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFireSensors(
      Color cardColor, Color textColor, Color subColor) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) =>
          Transform.scale(scale: _pulseAnim.value, child: child),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [AppColors.redAlert, AppColors.red, AppColors.orange],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.redAlert.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FIRE ALERT — NIVEAU CRITIQUE",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "Intervention immédiate requise",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _fireMiniCard("Temp", "78°C", Icons.thermostat_rounded),
                const SizedBox(width: 8),
                _fireMiniCard("Fumée", "Critique", Icons.cloud_rounded),
                const SizedBox(width: 8),
                _fireMiniCard("CO₂", "Élevé", Icons.air_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fireMiniCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOUTONS D'ACTION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActionButtons(Color cardColor, Color subColor) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call_rounded),
            label: const Text("Appeler les secours"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAlert,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send_rounded),
            label: const Text("Envoyer alerte à l'équipe"),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.water_drop_rounded),
            label: const Text("Activer l'extincteur robot"),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: AppColors.orange, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Le robot surveille la zone. Restez à distance de sécurité.",
                  style: TextStyle(color: AppColors.subText, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HISTORIQUE DES DÉTECTIONS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDetectionHistory(
      Color cardColor, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: AppColors.orange, size: 18),
              const SizedBox(width: 8),
              Text(
                "Historique des détections",
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._detectionHistory.map((e) => _historyItem(e, subColor)),
        ],
      ),
    );
  }

  Widget _historyItem(DetectionEvent e, Color subColor) {
    final c = _detectionColor(e.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_detectionIcon(e.status), color: c, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _detectionLabel(e.status),
                  style: TextStyle(
                      color: c, fontWeight: FontWeight.w800, fontSize: 13),
                ),
                Text(
                  "${e.zone} • Confiance : ${e.confidence}",
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            _timeAgo(e.time),
            style: TextStyle(color: subColor.withOpacity(0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }
}