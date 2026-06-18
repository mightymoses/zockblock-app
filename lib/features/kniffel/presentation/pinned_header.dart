import 'package:flutter/material.dart';

import 'scrollable_columns.dart';

class PinnedHeader extends StatelessWidget {
  const PinnedHeader({
    required this.title,
    required this.controller,
    required this.players,
    required this.labelWidth,
    required this.columnWidth,
    required this.sectionTitleStyle,
  });

  final String title;
  final ScrollController controller;
  final List<String> players;
  final double labelWidth;
  final double columnWidth;

  final TextStyle sectionTitleStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                title,
                style: sectionTitleStyle,
              ),
            ),
          ),
          Expanded(
            child: ScrollableColumns(
              controller: controller, // der headerController
              children: [
                for (final player in players)
                  SizedBox(
                    width: columnWidth,
                    child: Center(
                      child: CircleAvatar(
                        radius: 20,
                        child: Text(player.substring(0, 1)),
                      )
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}