import 'package:flutter/material.dart';
import 'kniffel_layout.dart';
import 'section_title.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, this.titleStyle, required this.child});

  final String? title;
  final TextStyle? titleStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          SectionTitle(title!, titleStyle!),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(horizontal: KniffelLayout.cardMargin),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: KniffelLayout.verticalPadding, bottom: KniffelLayout.verticalPadding, right: KniffelLayout.labelPadding),
            child: child
          ),
        ),
      ],
    );
  }
}