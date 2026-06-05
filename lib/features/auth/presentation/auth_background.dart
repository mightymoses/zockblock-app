import 'package:flutter/material.dart';
import 'dart:math';
import 'marquee_row.dart';

class AuthBackground extends StatelessWidget {
  final AnimationController controller;

  const AuthBackground({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.black;

    const double smallHeight = 48;
    final largeHeight = screenWidth / 2;
    final heightAfterLarge = screenHeight - (largeHeight * 2);
    final smallRowCount = ((heightAfterLarge / smallHeight).floor() ~/ 2) * 2;
    final totalRows = smallRowCount + 2;

    final random = Random();

    return ClipRect(
      child: SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(totalRows, (rowIndex) {
                    final isEven = rowIndex % 2 == 0;
                    final isFirstLargeRow = rowIndex == totalRows ~/ 2 - 1;
                    final isSecondLargeRow = rowIndex == totalRows ~/ 2;
                    final isLargeRow = isFirstLargeRow || isSecondLargeRow;
                    return MarqueeRow(
                      asset: isEven && !isSecondLargeRow || isFirstLargeRow
                          ? 'assets/graphics/zock.svg'
                          : 'assets/graphics/block.svg',
                      controller: controller,
                      reverse: !isEven,
                      color: color,
                      height: isLargeRow ? largeHeight : smallHeight,
                      speedMultiplier: isLargeRow ? random.nextInt(3) + 1 : random.nextInt(5) + 4,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
    );
  }
}