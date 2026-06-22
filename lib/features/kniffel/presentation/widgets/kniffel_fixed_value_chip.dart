import 'package:flutter/material.dart';
import '../../domain/kniffel_cell.dart';
import '../../domain/kniffel_field.dart';
import 'kniffel_chip_shell.dart';
import 'kniffel_cell_content.dart';

class KniffelFixedValueChip extends StatelessWidget {
  const KniffelFixedValueChip({
    super.key,
    required this.field,
    required this.cell,
    required this.onScore,
    required this.onCross,
    required this.textStyle,
  });

  final KniffelField field;
  final KniffelCell cell;
  final ValueChanged<int> onScore;
  final VoidCallback onCross;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final value = field.fixedScore!;

    return KniffelChipShell(
      onTap: cell.isEmpty ? () => onScore(value) : null,
      onLongPress:
          (field.canCross && cell.isEmpty) ? onCross : null,
      child: KniffelCellContent(cell: cell, style: textStyle),
    );
  }
}