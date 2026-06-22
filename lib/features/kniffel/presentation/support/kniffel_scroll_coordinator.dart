import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../domain/kniffel_field.dart';
import 'kniffel_layout.dart';

class KniffelScrollCoordinator {
  KniffelScrollCoordinator() {
    headerController = _group.addAndGet();
    _rowControllers = {for (final f in KniffelField.values) f: _group.addAndGet()};
    totalsController = _group.addAndGet();
  }

  final _group = LinkedScrollControllerGroup();
  double? _savedOffset;
  late final Map<KniffelField, ScrollController> _rowControllers;

  final verticalController = ScrollController();
  final viewportKey = GlobalKey();
  final activeChipKey = GlobalKey();
  final rowKeys = {for (final f in KniffelField.values) f: GlobalKey()};
  late final ScrollController headerController;
  late final ScrollController totalsController;

  ScrollController rowController(KniffelField field) {
    return _rowControllers[field]!;
  }

  void safe () {
    _savedOffset ??= verticalController.offset;
  }

  void restore({
    required bool Function() isStillActive
  }) {
    if (_savedOffset == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isStillActive()) return;
      final offset = _savedOffset;
      _savedOffset = null;
      if (offset == null || !verticalController.hasClients) return;
      verticalController.animateTo(offset,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  void scrollIntoView({
    required KniffelField field,
    required double padTotalHeight,
    required double labelWidth,
  }) {
    final rowBox = rowKeys[field]?.currentContext?.findRenderObject() as RenderBox?;
    final viewportBox = viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null || viewportBox == null || !rowBox.hasSize || !viewportBox.hasSize) return;

    // vertikal
    final rowTop = rowBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
    final rowBottom = rowTop + rowBox.size.height;
    final visibleTop = KniffelLayout.titleRowHeight;
    final visibleBottom = viewportBox.size.height - padTotalHeight;
    double dv = 0;
    if (rowBottom > visibleBottom) {
      dv = rowBottom - visibleBottom;
    } else if (rowTop < visibleTop) {
      dv = rowTop - visibleTop;
    }
    if (dv != 0) {
      final pos = verticalController.position;
      verticalController.animateTo((verticalController.offset + dv).clamp(pos.minScrollExtent, pos.maxScrollExtent),
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }

    // horizontal
    final chipBox = activeChipKey.currentContext?.findRenderObject() as RenderBox?;
    if (chipBox == null || !chipBox.hasSize) return;
    final chipLeft = chipBox.localToGlobal(Offset.zero, ancestor: rowBox).dx;
    final chipRight = chipLeft + chipBox.size.width;
    double dh = 0;
    if (chipRight > rowBox.size.width) {
      dh = chipRight - rowBox.size.width;
    } else if (chipLeft < labelWidth) {
      dh = chipLeft - labelWidth;
    }
    if (dh != 0) {
      _group.animateTo(_group.offset + dh,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  void dispose() {
    headerController.dispose();
    for (final c in _rowControllers.values) {
      c.dispose();
    }
    totalsController.dispose();
    verticalController.dispose();
  }
}