import 'package:flutter/material.dart';

import '../support/kniffel_layout.dart';

class KniffelSectionTitle extends StatelessWidget {
  const KniffelSectionTitle({
    super.key,
    required this.title,
    required this.sectionTitleStyle
  });

  final String title;
  final TextStyle sectionTitleStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KniffelLayout.titleRowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: KniffelLayout.cardMargin),
          child: Text(
            title,
            style: sectionTitleStyle,
          ),
        ),
      ),
    );
  }
}