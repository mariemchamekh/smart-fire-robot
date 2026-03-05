import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ─────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        brightness: Brightness.dark,
        surface: AppColors.card,
        primary: AppColors.redAlert,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: AppColors.subText),
        hintStyle: TextStyle(color: AppColors.subText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redAlert,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: BorderSide(color: AppColors.red.withOpacity(0.6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge:   TextStyle(color: AppColors.text),
        bodyMedium:  TextStyle(color: AppColors.text),
        bodySmall:   TextStyle(color: AppColors.subText),
        titleLarge:  TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        titleMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
      ),
      iconTheme: const IconThemeData(color: AppColors.iconSecondary),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.bg2),
    );
  }

  // ─────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        brightness: Brightness.light,
        surface: AppColors.cardLight,
        primary: AppColors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
        shadowColor: AppColors.red.withOpacity(0.1),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 1,
        shadowColor: AppColors.red.withOpacity(0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card2Light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: AppColors.subTextLight),
        hintStyle: TextStyle(color: AppColors.subTextLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textLight,
          side: BorderSide(color: AppColors.red.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge:   TextStyle(color: AppColors.textLight),
        bodyMedium:  TextStyle(color: AppColors.textLight),
        bodySmall:   TextStyle(color: AppColors.subTextLight),
        titleLarge:  TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900),
        titleMedium: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
      ),
      iconTheme: const IconThemeData(color: AppColors.iconSecLight),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.bg2Light),
    );
  }
}