import 'package:flutter/material.dart';
import '../kniffel_cell.dart';
import '../kniffel_field.dart';
import 'chip_shell.dart';
import 'kniffel_cell_content.dart';

class FixedValueChip extends StatelessWidget {
  const FixedValueChip({
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

    return ChipShell(
      onTap: cell.isEmpty ? () => onScore(value) : null,
      onLongPress:
          (field.canCross && cell.isEmpty) ? onCross : null,
      child: KniffelCellContent(cell, style: textStyle),
    );
  }
}