import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_colors.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bg : AppColors.bgLight;
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("EMERGENCY ALERT"),
        backgroundColor: AppColors.red.withOpacity(0.35),
        actions: const [ThemeToggleButton()],
      ),
      body: Stack(
        children: [
          // firetree2 background
          const Positioned.fill(
            child: Image(
              image: AssetImage("assets/images/firetree2.jpg"),
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(0.25),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    bgColor.withOpacity(0.95),
                    bgColor.withOpacity(0.75),
                    bgColor.withOpacity(0.4),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Pulsing alert banner
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  ),
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
                    child: Row(
                      children: const [
                        Icon(Icons.warning_rounded, color: Colors.white, size: 36),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FIRE ALERT!",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "HIGH RISK — Action immédiate requise",
                                style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Mini sensor cards
                Row(
                  children: [
                    _miniCard("Temp", "78°C", Icons.thermostat_rounded, AppColors.orange, cardColor),
                    const SizedBox(width: 10),
                    _miniCard("Smoke", "Critical", Icons.cloud_rounded, AppColors.redAlert, cardColor),
                  ],
                ),
                const SizedBox(height: 18),
                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call_rounded),
                    label: const Text("Call Emergency Services"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded),
                    label: const Text("Send Alert to Team"),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.water_drop_rounded),
                    label: const Text("Activate Robot Extinguisher"),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.red.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.orange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Le robot surveille la zone. Restez à distance de sécurité.",
                          style: TextStyle(color: subColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String label, String value, IconData icon, Color c, Color cardColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.subText, fontSize: 12)),
            Text(value, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}