import 'dart:math';
import 'package:flutter/material.dart';

/// Rotierende Kreisgrafik der Anmeldeseiten-Animation.
class SpinningCircle extends StatelessWidget {
  /// Erstellt einen drehenden Kreis.
  const SpinningCircle({
    required this.spinAnimation,
    required this.size,
    required this.isDark,
    required this.assetName,
    super.key,
    this.speedMultiplier = 1.0,
    this.reverse = false,
  });

  /// Animation, die die Drehung treibt.
  final CurvedAnimation spinAnimation;

  /// Kantenlänge der quadratischen Grafik.
  final double size;

  /// Ob die Dark-Variante der Grafik verwendet wird.
  final bool isDark;

  /// Faktor auf die Drehgeschwindigkeit.
  final double speedMultiplier;

  /// Ob gegen den Uhrzeigersinn gedreht wird.
  final bool reverse;

  /// Basisname der Grafik ohne Helligkeits-Suffix, z.B. `zock_links`.
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spinAnimation,
      builder: (context, child) {
        final angle =
            (reverse ? -spinAnimation.value : spinAnimation.value) *
            2 *
            pi *
            speedMultiplier;
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: Image.asset(
        isDark
            ? 'assets/images/${assetName}_dark.webp'
            : 'assets/images/${assetName}_bright.webp',
        width: size,
        height: size,
      ),
    );
  }
}
