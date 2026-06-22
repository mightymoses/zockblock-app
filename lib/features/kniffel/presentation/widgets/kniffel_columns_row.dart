import 'package:flutter/material.dart';

import '../support/kniffel_layout.dart';

class KniffelColumnsRow extends StatelessWidget {
  const KniffelColumnsRow({
    super.key,
    required this.count,
    required this.cellBuilder,
  });

  final int count;
  final Widget Function(int index) cellBuilder;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [for (var i = 0; i < count; i++) _cell(i)],
    );
  }

  Widget _cell(int i) {
    final content = SizedBox(
      width: KniffelLayout.columnContentWidth,
      child: Center(child: cellBuilder(i)),
    );

    final (double width, Alignment align) = switch (i) {
      _ when count == 1   => (KniffelLayout.columnWidth - KniffelLayout.columnPadding * 2, Alignment.center),
      0                   => (KniffelLayout.columnWidth - KniffelLayout.columnPadding, Alignment.centerLeft),
      _ when i == count-1 => (KniffelLayout.columnWidth - KniffelLayout.columnPadding, Alignment.centerRight),
      _                   => (KniffelLayout.columnWidth, Alignment.center),
    };

    return SizedBox(
      width: width,
      child: Align(alignment: align, child: content),
    );
  }
}