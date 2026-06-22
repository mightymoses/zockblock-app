import 'package:flutter/material.dart';
import 'package:zockblock_app/features/kniffel/presentation/widgets/kniffel_chip_shell.dart';

import '../support/kniffel_layout.dart';

class KniffelExpansionRow extends StatelessWidget {
  const KniffelExpansionRow({
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
            KniffelChipShell(
              child: Text('$value', style: chipStyle),
              onTap: () => onValueSelected?.call(value),
            )
        ]
      ),
    );
  }
}