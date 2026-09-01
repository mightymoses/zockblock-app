import 'dart:math';
import 'package:flutter/material.dart';

class SpinningCircle extends StatelessWidget {
  const SpinningCircle({
    required this.spinAnimation,
    required this.size,
    required this.isDark,
    required this.assetName,
    super.key,
    this.speedMultiplier = 1.0,
    this.reverse = false,
  });
  final CurvedAnimation spinAnimation;
  final double size;
  final bool isDark;
  final double speedMultiplier;
  final bool reverse;
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
