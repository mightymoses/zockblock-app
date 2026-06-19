import 'package:flutter/material.dart';
import 'package:zockblock_app/features/kniffel/presentation/kniffel_layout.dart';

import 'columns_row.dart';
import 'scrollable_columns.dart';

class PinnedHeader extends StatelessWidget {
  const PinnedHeader({
    super.key, 
    required this.controller,
    required this.players,
    required this.labelWidth,
    required this.titleArea,
  });

  final ScrollController controller;
  final List<String> players;
  final double labelWidth;
  final Widget titleArea;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KniffelLayout.titleRowHeight,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.only(left: KniffelLayout.cardMargin, right: KniffelLayout.cardMargin + KniffelLayout.horizontalPadding),
          child: Row(
            children: [
              SizedBox(
                width: labelWidth + KniffelLayout.horizontalPadding,
                child: titleArea,
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
      )
    );
  }
}