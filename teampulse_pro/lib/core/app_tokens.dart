import 'package:flutter/material.dart';

/// Échelle d'espacement (multiples de 4).
class AppSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Marge horizontale standard des écrans.
  static const double page = 20;

  /// Espace réservé en bas des listes pour la barre de navigation flottante.
  static const double navClearance = 120;

  /// Distance du bouton « + » flottant par rapport au bas de l'écran
  /// (au-dessus de la barre de navigation).
  static const double fabBottom = 100;
}

/// Rayons de bordure.
class AppRadius {
  static const double s = 12;
  static const double m = 16;
  static const double l = 22;
  static const double xl = 28;
  static const double pill = 999;
}

/// Durées d'animation. Elles tombent à zéro si l'utilisateur a activé
/// « réduire les animations » dans les réglages du système.
class AppMotion {
  static Duration fast(BuildContext c) => _d(c, 150);
  static Duration base(BuildContext c) => _d(c, 250);

  static Duration _d(BuildContext c, int ms) =>
      MediaQuery.disableAnimationsOf(c) ? Duration.zero : Duration(milliseconds: ms);
}
