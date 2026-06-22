import 'package:flutter/material.dart';

import '../../domain/kniffel_cell.dart';
import 'kniffel_chip_shell.dart';
import 'kniffel_cell_content.dart';

class KniffelSelectorChip extends StatelessWidget {
  const KniffelSelectorChip({
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
    return KniffelChipShell(
      onTap: cell.isEmpty ? onSelect : null,
      onLongPress: cell.isEmpty ? onCross : null, // oberer Block immer streichbar
      isActive: isActive,
      child: KniffelCellContent(cell: cell, style: textStyle),
    );
  }
}