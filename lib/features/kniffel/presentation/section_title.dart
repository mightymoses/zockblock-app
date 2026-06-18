import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, this.sectionTitleStyle);

  final String title;
  final TextStyle sectionTitleStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            title,
            style: sectionTitleStyle,
          ),
        ),
      ),
    );
  }
}