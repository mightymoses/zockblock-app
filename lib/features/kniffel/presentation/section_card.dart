import 'package:flutter/material.dart';
import 'kniffel_layout.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key, 
    required this.child
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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