import 'package:flutter/material.dart';

/// Singleton global pour le toggle dark/light mode.
/// Importé dans main.dart ET dans theme_toggle_button.dart
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// Instance globale unique
final themeNotifier = ThemeNotifier();