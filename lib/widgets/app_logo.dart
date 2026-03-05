import 'package:flutter/material.dart';

/// Widget logo réutilisable dans toute l'application.
///
/// Utilise automatiquement :
/// - [logonobg.png]      → fond transparent (par défaut)
/// - [logoblackbg.jpeg]  → sur fond sombre
/// - [logowhitebg.jpeg]  → sur fond clair
///
/// Exemple d'utilisation :
///   AppLogo(size: 48)
///   AppLogo.withBackground(size: 60)
class AppLogo extends StatelessWidget {
  final double size;
  final LogoVariant variant;

  const AppLogo({
    super.key,
    this.size = 40,
    this.variant = LogoVariant.transparent,
  });

  /// Choisit automatiquement la variante selon le thème actuel.
  const AppLogo.adaptive({
    super.key,
    this.size = 40,
    this.variant = LogoVariant.adaptive,
  });

  String get _assetPath {
    switch (variant) {
      case LogoVariant.blackBg:
        return 'assets/images/logoblackbg.jpeg';
      case LogoVariant.whiteBg:
        return 'assets/images/logowhitebg.jpeg';
      case LogoVariant.transparent:
      case LogoVariant.adaptive:
        return 'assets/images/logonobg.png';
    }
  }

  bool get _isRounded =>
      variant == LogoVariant.blackBg || variant == LogoVariant.whiteBg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pour la variante adaptive : choisit selon le thème
    String finalPath = _assetPath;
    if (variant == LogoVariant.adaptive) {
      finalPath = isDark
          ? 'assets/images/logoblackbg.jpeg'
          : 'assets/images/logowhitebg.jpeg';
    }

    final image = Image.asset(
      finalPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (_isRounded || variant == LogoVariant.adaptive) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: image,
      );
    }

    return image;
  }
}

enum LogoVariant { transparent, blackBg, whiteBg, adaptive }