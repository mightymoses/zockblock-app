import 'package:flutter/material.dart';

import 'columns_row.dart';
import 'kniffel_layout.dart';

class ExpansionRow extends StatelessWidget {
  const ExpansionRow({
    required this.values,
    this.onValueSelected,
  });

  final List<int> values;
  final ValueChanged<int>? onValueSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KniffelLayout.rowHeight,
      child: ColumnsRow(
        count: values.length,
        cellBuilder: (index) {
          final value = values[index];
          return GestureDetector(
            onTap: () => onValueSelected?.call(value),
            child: Container(
              width: KniffelLayout.chipWidth,
              height: KniffelLayout.chipHeight,
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(KniffelLayout.chipRadius),
              ),
              child: Center(child: Text('$value')),
            ),
          );
        },
      ),
    );
  }
}