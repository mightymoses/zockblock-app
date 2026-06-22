import 'package:flutter/material.dart';
import 'package:zockblock_app/features/kniffel/presentation/support/kniffel_layout.dart';

import 'kniffel_columns_row.dart';
import 'kniffel_scrollable_columns.dart';

class KniffelPinnedHeader extends StatelessWidget {
  const KniffelPinnedHeader({
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
                child: KniffelScrollableColumns(
                  controller: controller,
                  child: KniffelColumnsRow(
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