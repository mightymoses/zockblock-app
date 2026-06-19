import 'package:flutter/material.dart';

import 'kniffel_layout.dart';

class SectionTitleSwitcher extends StatelessWidget {
  const SectionTitleSwitcher({
    super.key,
    required this.scrollController,
    required this.viewportKey,
    required this.sectionKeys,
    required this.titles,
    required this.style,
  });

  final ScrollController scrollController;
  final GlobalKey viewportKey;
  final List<GlobalKey> sectionKeys;
  final List<String> titles;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KniffelLayout.titleRowHeight,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: scrollController, // ScrollController ist Listenable → rebaut beim Scrollen
          builder: (context, _) => _content(),
        ),
      ),
    );
  }

  Widget _content() {
    final viewport = viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null || !viewport.hasSize) return _title(0);

    double dyOf(GlobalKey k) {
      final box = k.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return double.infinity;
      return box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    }
    final dys = [for (final k in sectionKeys) dyOf(k)];

    var active = 0;
    const trigger = KniffelLayout.titleRowHeight / 2;
    for (var i = 0; i < dys.length; i++) {
      if (dys[i] <= trigger) active = i;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _title(active, key: ValueKey(active)), // Key-Wechsel triggert die Animation
    );
  }

  Widget _title(int index, {Key? key}) {
    return Align(
      key: key,
      alignment: Alignment.centerLeft,
      child: Text(titles[index], style: style),
    );
  }
}