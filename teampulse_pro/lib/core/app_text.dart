import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Styles de texte : Outfit pour les titres, DM Sans pour le reste.
/// Toutes les couleurs viennent de la palette, donc le mode sombre fonctionne.
class AppText {
  static TextStyle heading(BuildContext c, {double size = 22, Color? color}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? c.palette.ink,
        height: 1.2,
      );

  /// Texte principal (noms, titres de cartes).
  static TextStyle title(
    BuildContext c, {
    double size = 15,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? c.palette.ink,
        height: 1.3,
      );

  /// Texte secondaire (descriptions, dates).
  static TextStyle body(BuildContext c, {double size = 14, Color? color}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? c.palette.soft,
        height: 1.45,
      );

  /// Chiffres alignés (statistiques) : évite que les valeurs « sautent ».
  static TextStyle number(
    BuildContext c, {
    double size = 28,
    Color? color,
  }) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? c.palette.ink,
        height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Petits libellés (puces, badges) : jamais en dessous de 12 px.
  static TextStyle label(BuildContext c, {Color? color, double size = 12}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? c.palette.ink,
        height: 1.2,
      );
}
