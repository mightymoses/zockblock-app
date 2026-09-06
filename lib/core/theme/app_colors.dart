import 'package:flutter/material.dart';

/// Farben mit fester fachlicher Bedeutung, unabhängig vom Material-Theme.
class AppColors {
  AppColors._();

  /// Gewonnene Partie.
  static const Color win = Color(0xff52A788);

  /// Verlorene Partie.
  static const Color loss = Color(0xffC85A5A);

  /// Gold, dunklere Variante (z.B. für Verläufe).
  static const Color gold1 = Color(0xffAF9500);

  /// Gold, hellere Variante.
  static const Color gold2 = Color(0xffC9B037);

  /// Silber, hellere Variante.
  static const Color silver1 = Color(0xffD7D7D7);

  /// Silber, dunklere Variante.
  static const Color silver2 = Color(0xffB4B4B4);

  /// Bronze, dunklere Variante.
  static const Color bronze1 = Color(0xff6A3805);

  /// Bronze, hellere Variante.
  static const Color bronze2 = Color(0xffAD8A56);
}
