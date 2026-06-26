import 'package:flutter/material.dart';
import '../support/kniffel_layout.dart';

class KniffelSectionCard extends StatelessWidget {
  const KniffelSectionCard({
    super.key, 
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(horizontal: KniffelLayout.cardMargin),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: KniffelLayout.verticalPadding, horizontal: KniffelLayout.horizontalPadding),
            child: child
          ),
        ),
      ],
    );
  }
}