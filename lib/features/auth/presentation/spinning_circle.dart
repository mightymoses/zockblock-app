import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpinningCircle extends StatelessWidget {
  final CurvedAnimation spinAnimation;
  final double size;
  final bool isDark;
  final double speedMultiplier;
  final bool reverse;
  final String assetName;

  const SpinningCircle({
    super.key,
    required this.spinAnimation,
    required this.size,
    required this.isDark,
    required this.assetName,
    this.speedMultiplier = 1.0,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spinAnimation,
      builder: (context, child) {
        final angle = (reverse ? -spinAnimation.value : spinAnimation.value)
            * 2 * pi
            * speedMultiplier;
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: SvgPicture.asset(
        isDark
            ? 'assets/graphics/${assetName}_Dark.svg'
            : 'assets/graphics/${assetName}_Bright.svg',
        width: size,
        height: size,
      ),
    );
  }
}