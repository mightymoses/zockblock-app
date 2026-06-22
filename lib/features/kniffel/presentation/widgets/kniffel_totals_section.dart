import 'package:flutter/material.dart';
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
    required this.labelStyle,
    required this.emphasizedStyle,
    required this.players,
    required this.totalsController,
  });
 
  final double labelWidth;
  final TextStyle labelStyle;
  final TextStyle emphasizedStyle;
  final List<String> players;
  final ScrollController totalsController;

  @override
  Widget build(BuildContext context) {
    return KniffelSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Column(
              children: [
                for (final total in KniffelTotal.values)
                  SizedBox(
                    height: KniffelLayout.totalsRowHeight, 
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        total.label(AppLocalizations.of(context)!),
                        style: total.isEmphasized
                            ? emphasizedStyle
                            : labelStyle,
                        ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: KniffelScrollableColumns(
              controller: totalsController, 
              child: KniffelColumnsRow(
                count: players.length,
                cellBuilder: (_) => Column(
                  children: [
                    for (final _ in KniffelTotal.values)
                      const SizedBox(
                        height: KniffelLayout.totalsRowHeight,
                        child: Center(child: Text('0')), // Dummy
                      )
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