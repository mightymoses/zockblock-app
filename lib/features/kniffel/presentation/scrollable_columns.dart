

import 'package:flutter/material.dart';

class ScrollableColumns extends StatelessWidget {
  const ScrollableColumns({
    required this.controller,
    required this.children,
  });

  final ScrollController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: children,
            ),
          ),
        );
      },
    );
  }
}