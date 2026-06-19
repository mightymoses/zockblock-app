import 'package:flutter/material.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

import '../kniffel_cell.dart';
import '../kniffel_field.dart';
import 'columns_row.dart';
import 'fixed_value_chip.dart';
import 'input_chip.dart';
import 'kniffel_labels.dart';
import 'kniffel_layout.dart';
import 'scrollable_columns.dart';
import 'selector_chip.dart';

class SheetRow extends StatelessWidget {
  const SheetRow({
    super.key, 
    required this.field,
    required this.controller,
    required this.playerCount,
    required this.cellFor,        // KniffelCell pro Spieler
    required this.onScore,        // (player, value)
    required this.onCross,        // (player)
    required this.onSelect,       // (player) – öffnet die Expansion
    required this.onEditStart,    // () – Expansion öffnet sich, InputChip wird sichtbar
    required this.onEditEnd,      // () – Expansion schließt sich, InputChip wird
    required this.labelWidth,
    required this.labelStyle,
    required this.chipStyle,
    required this.activePlayer,
    required this.onActivate,
    required this.onCancel,
  });

  final KniffelField field;
  final ScrollController controller;
  final int playerCount;
  final KniffelCell Function(int player) cellFor;
  final void Function(int player, int value) onScore;
  final void Function(int player) onCross;
  final void Function(int player) onSelect;
  final VoidCallback onEditStart;
  final VoidCallback onEditEnd;
  final double labelWidth;
  final TextStyle labelStyle;
  final TextStyle chipStyle;
  final int? activePlayer;
  final void Function(int player) onActivate;
  final VoidCallback onCancel;

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
            child: ScrollableColumns(
              controller: controller,
              child: ColumnsRow(
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
      ChipKind.fixedValue => FixedValueChip(
          field: field,
          cell: cell,
          onScore: (v) => onScore(player, v),
          onCross: () => onCross(player),
          textStyle: chipStyle,
        ),
      // Platzhalter bis SelectorChip / InputChip gebaut sind:
      ChipKind.selector => SelectorChip(
          cell: cell,
          onSelect: () => onSelect(player),
          onCross: () => onCross(player),
          isActive: activePlayer == player, // neuer Row-Parameter, s.u.
          textStyle: chipStyle,
        ),
      ChipKind.manualInput => KniffelInputChip(
        field: field,
        cell: cell,
        isActive: activePlayer == player,        // NEU
        onActivate: () => onActivate(player),     // NEU
        onScore: (v) => onScore(player, v),       // Commit
        onCancel: onCancel,                       // NEU
        onCross: () => onCross(player),
        onEditStart: onEditStart,
        onEditEnd: onEditEnd,
        textStyle: chipStyle,
      ),
    };
  }
}