import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../support/kniffel_layout.dart';

class KniffelChipShell extends StatelessWidget {
  const KniffelChipShell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isActive = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress == null
      ? null
      : () {
          HapticFeedback.mediumImpact();
          onLongPress!();
      },
      child: Container(
        width: KniffelLayout.chipWidth,
        height: KniffelLayout.chipHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.orange.shade300,
          borderRadius: BorderRadius.circular(KniffelLayout.chipRadius),
          border: isActive
              ? Border.all(width: 2, color: Colors.orange.shade900)
              : null,
        ),
        child: child,
      ),
    );
  }
}