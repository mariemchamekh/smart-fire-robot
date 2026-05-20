import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_robot_service.dart';
import '../theme/app_colors.dart';

class RobotControlScreen extends StatefulWidget {
  const RobotControlScreen({super.key});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen>
    with TickerProviderStateMixin {

  bool   _firebaseConnected = false;
  String _lastCommand   = '—';
  String _activeDir     = '';

  // Animations
  late AnimationController _powerPulseCtrl;
  late Animation<double>   _powerPulseAnim;
  late AnimationController _statusCtrl;
  late Animation<double>   _statusAnim;

  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();

    _powerPulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _powerPulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _powerPulseCtrl, curve: Curves.easeInOut),
    );

    _statusCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _statusAnim = CurvedAnimation(parent: _statusCtrl, curve: Curves.easeOut);

    _listenToFirebase();
  }

  void _listenToFirebase() {
    _subs.add(firebaseRobotService.connectionStream.listen((connected) {
      if (mounted) setState(() => _firebaseConnected = connected);
    }));

    _subs.add(firebaseRobotService.liveDataStream.listen((data) {
      if (mounted) setState(() {
        if (data.status != "NO DATA") {
           // We assume if we have data, we are somewhat "connected" to the robot state
           // but firebase connection stream handles the actual DB connection.
        }
      });
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    _powerPulseCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  // ==================== COMMANDES MQTT ====================
  void _onDirectionDown(String dir) async {
    HapticFeedback.lightImpact();

    setState(() {
      _activeDir = dir;
      _lastCommand = dir.toUpperCase();
    });

    final connected = await firebaseRobotService.isConnected;

    if (!connected) {
      print("[Firebase] Déconnecté");
      return;
    }

    switch (dir) {
      case 'forward':
        firebaseRobotService.forward();
        break;
      case 'backward':
        firebaseRobotService.backward();
        break;
      case 'left':
        firebaseRobotService.left();
        break;
      case 'right':
        firebaseRobotService.right();
        break;
    }
  }

  void _onDirectionUp() async {
    setState(() => _activeDir = '');

    final connected = await firebaseRobotService.isConnected;

    if (!connected) {
      print("[Firebase] Déconnecté");
      return;
    }

    firebaseRobotService.stop();
  }

  Future<void> _emergencyStop() async {
    HapticFeedback.vibrate();

    final connected = await firebaseRobotService.isConnected;

    if (!connected) {
      print("[Firebase] Déconnecté");
      return;
    }

    setState(() {
      _activeDir = '';
      _lastCommand = 'STOP !!!';
    });

    firebaseRobotService.stop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.bg    : AppColors.bgLight;
    final cardColor = isDark ? AppColors.card  : AppColors.cardLight;
    final textColor = isDark ? AppColors.text  : AppColors.textLight;
    final subColor  = isDark ? AppColors.subText : AppColors.subTextLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Commande Robot"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildStatusBar(cardColor, textColor, subColor),
              const SizedBox(height: 16),
              _buildControlPanel(cardColor, textColor, subColor),
              const SizedBox(height: 16),
              _buildSecondaryActions(cardColor, textColor, subColor),
              const SizedBox(height: 16),
              _buildCommandLog(cardColor, textColor, subColor),
              const SizedBox(height: 16),
              _buildMqttNote(cardColor, subColor),
            ],
          ),
        ),
      ),
    );
  }

  // Le reste du code (design) reste presque identique
  Widget _buildStatusBar(Color card, Color text, Color sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _firebaseConnected ? AppColors.green.withOpacity(0.4) : AppColors.subText.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _statusDot(_firebaseConnected ? AppColors.green : AppColors.subText),
          const SizedBox(width: 8),
          Text(
            _firebaseConnected ? "Firebase Connecté" : "Firebase Déconnecté",
            style: TextStyle(
              color: _firebaseConnected ? AppColors.green : sub,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            _firebaseConnected ? "● LIVE" : "● OFFLINE",
            style: TextStyle(
              color: _firebaseConnected ? AppColors.green : sub,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(Color c) => AnimatedBuilder(
    animation: _powerPulseAnim,
    builder: (_, __) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6)],
      ),
    ),
  );

  Widget _buildControlPanel(Color card, Color text, Color sub) {
    final neonRed = const Color(0xFFFF2A2A);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A), // Very dark background
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: neonRed.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: neonRed.withOpacity(0.15), blurRadius: 30, spreadRadius: 5),
          BoxShadow(color: Colors.black.withOpacity(0.9), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          // En-tête : Power & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPowerSection(neonRed),
              _buildStatusSection(neonRed),
            ],
          ),
          const SizedBox(height: 30),
          
          // D-PAD
          SizedBox(
            height: 260,
            width: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fond décoratif en croix
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: neonRed.withOpacity(0.1), width: 1),
                  ),
                ),
                
                // Bouton central
                _centerButton(neonRed),
                
                // Haut
                Positioned(
                  top: 0,
                  child: _dirButton(Icons.arrow_upward_rounded, 'forward', neonRed),
                ),
                // Bas
                Positioned(
                  bottom: 0,
                  child: _dirButton(Icons.arrow_downward_rounded, 'backward', neonRed),
                ),
                // Gauche
                Positioned(
                  left: 0,
                  child: _dirButton(Icons.arrow_back_rounded, 'left', neonRed),
                ),
                // Droite
                Positioned(
                  right: 0,
                  child: _dirButton(Icons.arrow_forward_rounded, 'right', neonRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPowerSection(Color neonRed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "POWER", 
          style: TextStyle(color: neonRed, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: neonRed, width: 2.5),
            boxShadow: [
              BoxShadow(color: neonRed.withOpacity(0.4), blurRadius: 12),
            ],
            color: const Color(0xFF1A0505),
          ),
          child: Icon(Icons.power_settings_new_rounded, color: neonRed, size: 24),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text("ON", style: TextStyle(color: neonRed, fontWeight: FontWeight.w800, fontSize: 10)),
            const SizedBox(width: 6),
            Container(
              width: 14, 
              height: 6, 
              decoration: BoxDecoration(
                color: neonRed, 
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: neonRed, blurRadius: 6)],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatusSection(Color neonRed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "STATUS", 
          style: TextStyle(color: neonRed, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Petit point rond
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: neonRed, shape: BoxShape.circle, boxShadow: [BoxShadow(color: neonRed, blurRadius: 4)]),
            ),
            const SizedBox(width: 8),
            // Barres inclinées
            ...List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: 10,
                height: 14,
                transform: Matrix4.skewX(-0.4), // Inclinaison
                decoration: BoxDecoration(
                  color: neonRed.withOpacity(index < 4 ? 1.0 : 0.2), // 4 barres pleines
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: index < 4 ? [BoxShadow(color: neonRed.withOpacity(0.6), blurRadius: 4)] : [],
                ),
              );
            }),
          ],
        )
      ],
    );
  }

  Widget _centerButton(Color neonRed) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A0505),
        border: Border.all(color: neonRed, width: 3),
        boxShadow: [
          BoxShadow(color: neonRed.withOpacity(0.5), blurRadius: 25, spreadRadius: 2),
        ]
      ),
      child: Center(
        child: Icon(Icons.smart_toy_outlined, color: neonRed, size: 40),
      ),
    );
  }

  Widget _dirButton(IconData icon, String dir, Color neonRed) {
    bool isActive = _activeDir == dir;
    return GestureDetector(
      onTapDown: (_) {
        _onDirectionDown(dir);
      },
      onTapUp: (_) {
        _onDirectionUp();
      },
      onTapCancel: () {
        _onDirectionUp();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: isActive ? neonRed.withOpacity(0.3) : const Color(0xFF120303),
          borderRadius: BorderRadius.circular(20), // Forme semi-octogonale avec des bords arrondis
          border: Border.all(
            color: isActive ? neonRed : neonRed.withOpacity(0.4),
            width: isActive ? 3 : 2,
          ),
          boxShadow: isActive ? [
            BoxShadow(color: neonRed.withOpacity(0.8), blurRadius: 20, spreadRadius: 2)
          ] : [
            BoxShadow(color: neonRed.withOpacity(0.1), blurRadius: 5)
          ],
        ),
        child: Icon(
          icon, 
          color: isActive ? Colors.white : neonRed, 
          size: 45,
          shadows: isActive ? [Shadow(color: Colors.white, blurRadius: 10)] : [],
        ),
      ),
    );
  }

  Widget _buildSecondaryActions(Color card, Color text, Color sub) {
    return Row(
      children: [
        // Extincteur (désactivé pour l'instant)
        Expanded(
          child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Extincteur non implémenté côté robot")),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
              ),
              child: Column(children: [
                const Icon(Icons.water_drop_rounded, color: AppColors.orange, size: 28),
                const SizedBox(height: 6),
                Text("Extincteur", style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _emergencyStop,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.redAlert.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.redAlert.withOpacity(0.4)),
              ),
              child: Column(children: [
                const Icon(Icons.pan_tool_rounded, color: AppColors.redAlert, size: 28),
                const SizedBox(height: 6),
                const Text("STOP URGENCE", style: TextStyle(color: AppColors.redAlert, fontWeight: FontWeight.w900, fontSize: 12)),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommandLog(Color card, Color text, Color sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.terminal_rounded, color: AppColors.orange, size: 18),
          const SizedBox(width: 10),
          Text("Dernière commande :", style: TextStyle(color: sub, fontSize: 12)),
          const SizedBox(width: 8),
          Text(_lastCommand, style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMqttNote(Color card, Color sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.orange, size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Commandes envoyées via Firebase vers le Raspberry Pi",
              style: TextStyle(fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}