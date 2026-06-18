import 'package:flutter/material.dart';

import '../kniffel_cell.dart';
import 'chip_shell.dart';
import 'kniffel_cell_content.dart';

class SelectorChip extends StatelessWidget {
  const SelectorChip({
    super.key,
    required this.cell,
    required this.onSelect,
    required this.onCross,
    this.isActive = false,
    required this.textStyle,
  });

  final KniffelCell cell;
  final VoidCallback onSelect; // öffnet die Auswahl-Zeile
  final VoidCallback onCross;
  final bool isActive;         // Auswahl gerade offen
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return ChipShell(
      onTap: cell.isEmpty ? onSelect : null,
      onLongPress: cell.isEmpty ? onCross : null, // oberer Block immer streichbar
      isActive: isActive,
      child: KniffelCellContent(cell, style: textStyle),
    );
  }
}