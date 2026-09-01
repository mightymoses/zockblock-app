import 'package:flutter/material.dart';

class MarqueeRow extends StatelessWidget {
  const MarqueeRow({
    required this.asset,
    required this.marqueAnimation,
    required this.reverse,
    required this.color,
    required this.height,
    super.key,
    this.speedMultiplier = 1.0,
  });
  final String asset;
  final CurvedAnimation marqueAnimation;
  final bool reverse;
  final Color color;
  final double height;
  final double speedMultiplier;

  double get _itemWidth => height * 2.2;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: height,
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: marqueAnimation,
            builder: (context, child) {
              final progress = reverse
                  ? (1 - marqueAnimation.value)
                  : marqueAnimation.value;
              final offset =
                  -(progress * _itemWidth * speedMultiplier) - (height * 0.1);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                12,
                (_) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: height * 0.1),
                  child: Image.asset(
                    asset,
                    height: height,
                    color: color,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
