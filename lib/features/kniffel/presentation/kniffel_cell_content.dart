import 'package:flutter/material.dart';
import '../kniffel_cell.dart';

class KniffelCellContent extends StatelessWidget {
  const KniffelCellContent(this.cell, {super.key, required this.style});

  final KniffelCell cell;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return switch (cell) {
      EmptyCell() =>  Text('-', style: style),
      ScoredCell(:final value) => Text('$value', style: style),
      CrossedCell() =>  Text('X', style: style),
    };
  }
}