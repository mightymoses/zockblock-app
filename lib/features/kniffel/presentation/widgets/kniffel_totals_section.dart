import 'package:flutter/material.dart';
import 'package:zockblock_app/core/theme/app_colors.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

import '../../domain/kniffel_total.dart';
import 'kniffel_columns_row.dart';
import '../support/kniffel_field_labels.dart';
import '../support/kniffel_layout.dart';
import 'kniffel_scrollable_columns.dart';
import 'kniffel_section_card.dart';

class KniffelTotalsSection extends StatelessWidget {
   const KniffelTotalsSection({
    super.key, 
    required this.labelWidth,
    required this.style,
    required this.emphasizedStyle,
    required this.players,
    required this.totalsController,
  });
 
  final double labelWidth;
  final TextStyle style;
  final TextStyle emphasizedStyle;
  final List<String> players;
  final ScrollController totalsController;

  Color? _getColor(int totalValue) {
    if (totalValue > 0) {
      return AppColors.win;
    } else if (totalValue < 0) {
      return AppColors.loss;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<List<int>> totals = List.generate(players.length, (_) => List.generate(KniffelTotal.values.length, (_) => 0));

    return KniffelSectionCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Column(
              children: [
                for (final total in KniffelTotal.values)
                  ...[
                    SizedBox(
                      height: KniffelLayout.totalsRowHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          total.label(AppLocalizations.of(context)!),
                          style: total.isEmphasized
                              ? emphasizedStyle
                              : style,
                          ),
                      ),
                    ),
                    if (total.followedByDivider) Divider(color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2))
                  ]
              ],
            ),
          ),
          Expanded(
            child: KniffelScrollableColumns(
              controller: totalsController, 
              child: KniffelColumnsRow(
                isTotalsRow: true,
                count: players.length,
                cellBuilder: (playerIndex) => Column(
                  children: [
                    for (final total in KniffelTotal.values)
                      ...[
                        SizedBox(
                          height: KniffelLayout.totalsRowHeight,
                          child: Center(
                            child: Text(
                              totals[playerIndex][total.index].toString(),
                              style: total.isEmphasized
                                ? emphasizedStyle
                                : (total == KniffelTotal.difference
                                  ? style.copyWith(color: _getColor(totals[playerIndex][total.index]))
                                  : style),
                            ),
                          ),
                        ),
                        if (total.followedByDivider) Divider(color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2))
                      ]
                  ]
                )
              )
            ),
          ),
        ],
      ),
    );
  }
}