import 'package:flutter/material.dart';
import 'package:zockblock_app/features/kniffel/presentation/chip_shell.dart';

import 'kniffel_layout.dart';

class ExpansionRow extends StatelessWidget {
  const ExpansionRow({
    super.key, 
    required this.values,
    this.onValueSelected,
    required this.chipStyle,
  });

  final List<int> values;
  final ValueChanged<int>? onValueSelected;
  final TextStyle chipStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KniffelLayout.rowHeight,
      child: Row(
        spacing: KniffelLayout.horizontalPadding,
        children: [
          for (final value in values)
            ChipShell(
              child: Text('$value', style: chipStyle),
              onTap: () => onValueSelected?.call(value),
            )
        ]
      ),
    );
  }
}