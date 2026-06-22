import 'package:flutter/material.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

import '../../domain/kniffel_cell.dart';
import '../../domain/kniffel_field.dart';
import 'kniffel_columns_row.dart';
import 'kniffel_fixed_value_chip.dart';
import 'kniffel_input_chip.dart';
import '../support/kniffel_field_labels.dart';
import '../support/kniffel_layout.dart';
import 'kniffel_scrollable_columns.dart';
import 'kniffel_selector_chip.dart';

class KniffelSheetRow extends StatelessWidget {
  const KniffelSheetRow({
    super.key, 
    required this.field,
    required this.controller,
    required this.playerCount,
    required this.cellFor,        // KniffelCell pro Spieler
    required this.onScore,        // (player, value)
    required this.onCross,        // (player)
    required this.onSelect,       // (player) – öffnet die Expansion
    required this.labelWidth,
    required this.labelStyle,
    required this.chipStyle,
    required this.activePlayer,
    required this.onActivate,
    required this.inputBuffer,
    required this.activeChipKey,
  });

  final KniffelField field;
  final ScrollController controller;
  final int playerCount;
  final KniffelCell Function(int player) cellFor;
  final void Function(int player, int value) onScore;
  final void Function(int player) onCross;
  final void Function(int player) onSelect;
  final double labelWidth;
  final TextStyle labelStyle;
  final TextStyle chipStyle;
  final int? activePlayer;
  final void Function(int player) onActivate;
  final String inputBuffer;
  final GlobalKey activeChipKey;

  @override
  Widget build(BuildContext context) {
    final label = field.label(AppLocalizations.of(context)!);
    return SizedBox(
      height: KniffelLayout.rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: labelStyle),
          ),
          Expanded(
            child: KniffelScrollableColumns(
              controller: controller,
              child: KniffelColumnsRow(
                count: playerCount,
                cellBuilder: (player) => _chipFor(player),
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipFor(int player) {
    final cell = cellFor(player);
    return switch (field.chipKind) {
      ChipKind.fixedValue => KniffelFixedValueChip(
          field: field,
          cell: cell,
          onScore: (v) => onScore(player, v),
          onCross: () => onCross(player),
          textStyle: chipStyle,
        ),
      // Platzhalter bis SelectorChip / InputChip gebaut sind:
      ChipKind.selector => KniffelSelectorChip(
          cell: cell,
          onSelect: () => onSelect(player),
          onCross: () => onCross(player),
          isActive: activePlayer == player, // neuer Row-Parameter, s.u.
          textStyle: chipStyle,
        ),
      ChipKind.manualInput => KniffelInputChip(
        key: activePlayer == player ? activeChipKey : null,
        field: field,
        cell: cell,
        isActive: activePlayer == player,        // NEU
        onActivate: () => onActivate(player),     // NEU
        onCross: () => onCross(player),
        textStyle: chipStyle,
        buffer: inputBuffer,
      ),
    };
  }
}