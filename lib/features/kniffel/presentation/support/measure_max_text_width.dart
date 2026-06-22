import 'package:flutter/material.dart';

double measureMaxTextWidth(
  BuildContext context,
  List<String> texts,
  TextStyle style,
) {
  final scaler = MediaQuery.textScalerOf(context);
  var max = 0.0;
  for (final text in texts) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaler,
    )..layout();
    if (painter.width > max) max = painter.width;
    painter.dispose();
  }
  return max;
}