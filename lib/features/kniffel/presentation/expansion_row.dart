import 'package:flutter/material.dart';

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
      height: 56,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            for (final value in values) ...[
              GestureDetector(
                onTap: () => onValueSelected?.call(value),
                child: Container(
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text('$value')),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}