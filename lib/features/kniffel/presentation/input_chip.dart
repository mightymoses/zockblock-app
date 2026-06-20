import 'package:flutter/material.dart';

import '../kniffel_cell.dart';
import '../kniffel_field.dart';
import 'chip_shell.dart';
import 'kniffel_cell_content.dart';

class KniffelInputChip extends StatelessWidget {
  const KniffelInputChip({
    super.key,
    required this.field,
    required this.cell,
    required this.isActive,
    required this.onActivate,
    required this.onCross,
    required this.textStyle,
    required this.buffer,
  });

  final KniffelField field;
  final KniffelCell cell;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onCross;
  final TextStyle textStyle;
  final String buffer;

  @override
  Widget build(BuildContext context) {
    return ChipShell(
      onTap: cell.isEmpty && !isActive ? onActivate : null,
      onLongPress: (field.canCross && cell.isEmpty && !isActive)
          ? onCross
          : null,
      isActive: isActive,
      child: isActive ? Text(buffer, style: textStyle) : KniffelCellContent(cell: cell, style: textStyle),
    );
  }
}