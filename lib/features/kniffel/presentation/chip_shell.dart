import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChipShell extends StatelessWidget {
  const ChipShell({
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
        width: 56,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.orange.shade300,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(width: 2, color: Colors.orange.shade900)
              : null,
        ),
        child: child,
      ),
    );
  }
}