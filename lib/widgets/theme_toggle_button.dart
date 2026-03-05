import 'package:flutter/material.dart';
import '../services/theme_notifier.dart';
import '../theme/app_colors.dart';

/// Bouton toggle dark/light mode réutilisable dans AppBar ou Drawer.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => themeNotifier.toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.card.withOpacity(0.8)
              : AppColors.cardLight.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.orange.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark ? AppColors.orange : AppColors.red,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              isDark ? "Light" : "Dark",
              style: TextStyle(
                color: isDark ? AppColors.text : AppColors.textLight,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}