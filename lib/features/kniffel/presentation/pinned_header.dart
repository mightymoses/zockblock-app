import 'package:flutter/material.dart';
import 'package:zockblock_app/features/kniffel/presentation/kniffel_layout.dart';

import 'columns_row.dart';
import 'scrollable_columns.dart';

class PinnedHeader extends StatelessWidget {
  const PinnedHeader({
    required this.title,
    required this.controller,
    required this.players,
    required this.labelWidth,
    required this.sectionTitleStyle,
  });

  final String title;
  final ScrollController controller;
  final List<String> players;
  final double labelWidth;

  final TextStyle sectionTitleStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KniffelLayout.titleRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: KniffelLayout.cardMargin, right: KniffelLayout.cardMargin + KniffelLayout.labelPadding),
        child: Row(
          children: [
            SizedBox(
              width: labelWidth,
              child: Text(
                  title,
                  style: sectionTitleStyle,
                ),
            ),
            Expanded(
              child: ScrollableColumns(
                controller: controller,
                child: ColumnsRow(
                  count: players.length,
                  cellBuilder: (index) => CircleAvatar(
                      radius: KniffelLayout.avatarRadius,
                      child: Text(players[index].substring(0, 1)),
                    ),
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}