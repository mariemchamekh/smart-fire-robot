import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_colors.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Live Camera"),
        actions: const [ThemeToggleButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.red.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.videocam_off_rounded,
                      color: isDark ? AppColors.iconSecondary : AppColors.iconSecLight, size: 36),
                ),
                const SizedBox(height: 18),
                Text(
                  "Flux Caméra",
                  style: TextStyle(
                    color: isDark ? AppColors.text : AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  kIsWeb
                      ? "Sur Chrome (Web), la caméra peut être limitée.\nTeste sur Android Emulator / Téléphone."
                      : "Intégration caméra disponible sur Android.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subColor, fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}