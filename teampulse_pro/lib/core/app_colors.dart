import 'package:flutter/material.dart';

/// Couleurs de marque (identiques dans les thèmes clair et sombre).
///
/// Pour les couleurs qui changent selon le thème (fond, cartes, textes),
/// utilisez `context.palette` (voir `app_palette.dart`).
class AppColors {
  static const primary = Color(0xFF5B4CFF); // bleu pulse
  static const primaryLight = Color(0xFF6B5BFF);
  static const primaryDeep = Color(0xFF3A2BD6);
  static const mint = Color(0xFF2ED8A7); // avancement / terminé
  static const coral = Color(0xFFFF5C7A); // retards / alertes
  static const amber = Color(0xFFFFB84D); // moyenne / bientôt
  static const navy = Color(0xFF1A1A4B); // titres (thème clair)

  /// Texte secondaire : ratio de contraste 6:1 sur fond blanc (WCAG AA).
  static const textSoft = Color(0xFF5F5D88);
  static const background = Color(0xFFF4F2FF); // fond des écrans (clair)
  static const card = Colors.white;

  static const gradientPrimary = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dégradé « héro » des grandes cartes (tableau de bord, profil).
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF5F50F0), primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
