import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Couleurs « sémantiques » qui s'adaptent au thème clair / sombre.
///
/// Usage : `final p = context.palette;` puis `p.card`, `p.ink`, `p.soft`…
/// Les couleurs sombres sont des variantes plus claires et désaturées
/// (et non des couleurs inversées) pour garder un contraste >= 4,5:1.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final bool isDark;
  final Color background; // fond des écrans
  final Color card; // fond des cartes
  final Color cardAlt; // surfaces secondaires (colonnes Kanban, champs)
  final Color ink; // titres et texte principal
  final Color soft; // texte secondaire
  final Color outline; // bordures et séparateurs
  final Color primaryInk; // violet lisible comme texte
  final Color mintInk;
  final Color coralInk;
  final Color amberInk;

  const AppPalette({
    required this.isDark,
    required this.background,
    required this.card,
    required this.cardAlt,
    required this.ink,
    required this.soft,
    required this.outline,
    required this.primaryInk,
    required this.mintInk,
    required this.coralInk,
    required this.amberInk,
  });

  static const light = AppPalette(
    isDark: false,
    background: AppColors.background,
    card: Colors.white,
    cardAlt: Color(0xFFE9E6FF),
    ink: AppColors.navy,
    soft: AppColors.textSoft,
    outline: Color(0xFFE2DFF7),
    primaryInk: Color(0xFF4A3BE0),
    mintInk: Color(0xFF076B52),
    coralInk: Color(0xFFC41E42),
    amberInk: Color(0xFF8A5A00),
  );

  static const dark = AppPalette(
    isDark: true,
    background: Color(0xFF0F0F26),
    card: Color(0xFF1A1A3C),
    cardAlt: Color(0xFF25254F),
    ink: Color(0xFFF3F2FF),
    soft: Color(0xFFB9B8DA),
    outline: Color(0xFF35356B),
    primaryInk: Color(0xFFA79DFF),
    mintInk: Color(0xFF4FE3BC),
    coralInk: Color(0xFFFF8CA2),
    amberInk: Color(0xFFFFC970),
  );

  /// Couleur de texte lisible pour un accent donné (corail, menthe…).
  /// Les accents vifs servent aux fonds, ces variantes servent au texte.
  Color inkFor(Color accent) {
    if (accent == AppColors.coral) return coralInk;
    if (accent == AppColors.mint) return mintInk;
    if (accent == AppColors.amber) return amberInk;
    if (accent == AppColors.primary) return primaryInk;
    return accent;
  }

  @override
  AppPalette copyWith({
    bool? isDark,
    Color? background,
    Color? card,
    Color? cardAlt,
    Color? ink,
    Color? soft,
    Color? outline,
    Color? primaryInk,
    Color? mintInk,
    Color? coralInk,
    Color? amberInk,
  }) {
    return AppPalette(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      ink: ink ?? this.ink,
      soft: soft ?? this.soft,
      outline: outline ?? this.outline,
      primaryInk: primaryInk ?? this.primaryInk,
      mintInk: mintInk ?? this.mintInk,
      coralInk: coralInk ?? this.coralInk,
      amberInk: amberInk ?? this.amberInk,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
