import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarqueeRow extends StatelessWidget {
  final String asset;
  final AnimationController controller;
  final bool reverse;
  final Color color;
  final double height;
  final double speedMultiplier;

  double get _itemWidth => height * 2.2;

  const MarqueeRow({
    super.key,
    required this.asset,
    required this.controller,
    required this.reverse,
    required this.color,
    required this.height,
    this.speedMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: height,
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final progress = reverse ? (1 - controller.value) : controller.value;
              final offset = -(progress * _itemWidth * speedMultiplier) - (height * 0.1);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(12, (_) =>
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: height * 0.1),
                  child: SvgPicture.asset(
                    asset,
                    height: height,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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