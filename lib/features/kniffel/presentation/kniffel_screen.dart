import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:zockblock_app/features/kniffel/presentation/measure_max_text_width.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

import '../kniffel_field.dart';
import '../kniffel_total.dart';
import '../kniffel_cell.dart';
import 'columns_row.dart';
import 'expansion_row.dart';
import 'kniffel_labels.dart';
import 'kniffel_layout.dart';
import 'num_pad.dart';
import 'pinned_header.dart';
import 'scrollable_columns.dart';
import 'section_title.dart';
import 'section_title_switcher.dart';
import 'sheet_row.dart';
import 'section_card.dart';

class KniffelScreen extends StatefulWidget {
  const KniffelScreen({super.key});

  @override
  State<KniffelScreen> createState() => _KniffelScreenState();
}

class _KniffelScreenState extends State<KniffelScreen> {
  static final _upperFields = KniffelField.values.where((f) => f.isUpper).toList();
  static final _lowerFields = KniffelField.values.where((f) => !f.isUpper).toList();
  
  static const _players = ['Moritz', 'Lisa', 'Tim', 'Anna', 'Max', 'Sophie'];

  final _scrollGroup = LinkedScrollControllerGroup();
  late final ScrollController _headerController;
  late final List<ScrollController> _rowControllers;
  late final ScrollController _totalsController;
  final _verticalController = ScrollController();

  final _viewportKey = GlobalKey();
  final _sectionKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  int get _rowCount => _upperFields.length + _lowerFields.length;

  double _labelWidth = 0;

  (KniffelField, int player)? _activeCell;

  void _activate(KniffelField field, int player) {
    _savedScrollOffset ??= _verticalController.offset;
    setState(() {
      _activeCell = (field, player);
      _inputBuffer = '';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollActiveIntoView());
  }

  void _deactivate() {
    setState(() {
      _activeCell = null;
      _inputBuffer = '';
    });
    _onEditEnd();
  }

  void _toggleSelector(KniffelField field, int player) {
    final target = (field, player);
    setState(() {
      _activeCell = (_activeCell == target) ? null : target;
    });
    if (_activeCell == target) {
      _onEditEnd();
    }
  }

  void _setValue(KniffelField field, int player, int value) {
    setState(() {
      _cells[(field, player)] = ScoredCell(value);
      _activeCell = null;
      _inputBuffer = '';
    });
    _onEditEnd();
  }

  void _crossOut(KniffelField field, int player) {
    setState(() {
      _cells[(field, player)] = const CrossedCell();
      _activeCell = null;
    });
    _onEditEnd();
  }

  final Map<(KniffelField, int player), KniffelCell> _cells = {};
  KniffelCell _cellFor(KniffelField field, int player) =>
    _cells[(field, player)] ?? const EmptyCell();

  double? _savedScrollOffset;

  String _inputBuffer = '';
  final _rowKeys = {for (final f in KniffelField.values) f: GlobalKey()};
  final _activeChipKey = GlobalKey();
  double get _padTotalHeight => KniffelLayout.numPadHeight + MediaQuery.viewPaddingOf(context).bottom;

  @override
  void initState() {
    super.initState();
    _headerController = _scrollGroup.addAndGet();
    _rowControllers =
        List.generate(_rowCount, (_) => _scrollGroup.addAndGet());
    _totalsController = _scrollGroup.addAndGet(); 
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (final controller in _rowControllers) {
      controller.dispose();
    }
    _verticalController.dispose();
    super.dispose();
  }

  void _onEditEnd() {
    if (_savedScrollOffset == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_activeCell != null) return;
      final offset = _savedScrollOffset;
      _savedScrollOffset = null;
      if (offset == null || !_verticalController.hasClients) return;
      _verticalController.animateTo(offset,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  void _onDigit(int d) {
    if (_inputBuffer.length >= 2) return;
    setState(() => _inputBuffer += '$d');
    _scrollActiveIntoView();
  }

  void _onDelete() {
    if (_inputBuffer.isEmpty) return;
    setState(() => _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1));
    _scrollActiveIntoView();
  }

  void _onEnter() {
    final active = _activeCell;
    if (active == null) return;
    final (field, player) = active;
    final value = int.tryParse(_inputBuffer);
    if (value != null && field.isValidManualValue(value)) {
      _setValue(field, player, value);
    } else {
      _deactivate();
    }
  }

  void _scrollActiveIntoView() {
    // Vertikal:
    final rowBox = _rowKeys[_activeCell?.$1]?.currentContext?.findRenderObject() as RenderBox?;
    final viewportBox = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null || viewportBox == null || !rowBox.hasSize || !viewportBox.hasSize) return;

    final rowTop = rowBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy; // relativ zum Viewport-Top
    final rowBottom = rowTop + rowBox.size.height;

    final visibleTop = KniffelLayout.titleRowHeight;                              // unter dem Header
    final visibleBottom = viewportBox.size.height - _padTotalHeight;              // über dem Pad

    double dv = 0;
    if (rowBottom > visibleBottom) {
      dv = rowBottom - visibleBottom;   // Zeile zu weit unten → Offset erhöhen (Inhalt hoch)
    } else if (rowTop < visibleTop) {
      dv = rowTop - visibleTop;         // Zeile hinterm Header → Offset verringern (Inhalt runter)
    }
    if (dv != 0) {
      final pos = _verticalController.position;
      final target = (_verticalController.offset + dv).clamp(pos.minScrollExtent, pos.maxScrollExtent);
      _verticalController.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }

    // Horizontal:
    final chipBox = _activeChipKey.currentContext?.findRenderObject() as RenderBox?;
    if (chipBox == null || !chipBox.hasSize) return;

    final chipLeft = chipBox.localToGlobal(Offset.zero, ancestor: rowBox).dx; // relativ zur Zeile
    final chipRight = chipLeft + chipBox.size.width;

    final visibleLeft = _labelWidth;          // links beginnt der scrollbare Bereich
    final visibleRight = rowBox.size.width;    // rechts endet die Zeile

    double dh = 0;
    if (chipRight > visibleRight) {
      dh = chipRight - visibleRight;   // Chip rechts raus → Gruppe nach rechts (Offset erhöhen)
    } else if (chipLeft < visibleLeft) {
      dh = chipLeft - visibleLeft;     // Chip links hinter der Label-Spalte → Offset verringern
    }
    if (dh != 0) {
      _scrollGroup.animateTo(
        _scrollGroup.offset + dh,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyLarge!;
    final emphasizedStyle = labelStyle.copyWith(fontWeight: FontWeight.bold);
    final sectionTitleStyle = theme.textTheme.titleMedium!;
    final chipStyle = theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    _labelWidth = [
      measureMaxTextWidth(context,
          [for (final f in KniffelField.values) f.label(l10n)], labelStyle),
      measureMaxTextWidth(context,
          [for (final t in KniffelTotal.values) t.label(l10n)], emphasizedStyle),
      measureMaxTextWidth(context,
          [l10n.kniffelSectionUpper, l10n.kniffelSectionLower, l10n.kniffelSectionTotals],
          sectionTitleStyle),
    ].reduce(max) + KniffelLayout.labelToChipSpacing;

    final padOpen = _activeCell != null && _activeCell!.$1.chipKind == ChipKind.manualInput;
    

    return PopScope(
      canPop: _activeCell == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _deactivate();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: Stack(
          children: [
            SingleChildScrollView(
              key: _viewportKey,
              controller: _verticalController,
              padding: EdgeInsets.only(
                bottom: padOpen ? _padTotalHeight : 0
              ),
              child: Column(
                children: [
                  SectionTitle(
                    key: _sectionKeys[0],
                    title: l10n.kniffelSectionUpper,
                    sectionTitleStyle: sectionTitleStyle,
                  ),
                  SectionCard(
                    child: Column(
                      children: [
                        for (final field in _upperFields) ...[
                          _buildRow(field, labelStyle, _labelWidth, chipStyle),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: _activeCell?.$1 == field
                                ? ExpansionRow(
                                    values: field.selectorValues!,
                                    onValueSelected: (value) => _setValue(field, _activeCell!.$2, value),
                                    chipStyle: chipStyle,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ]
                    )
                  ),
                  SectionTitle(
                    key: _sectionKeys[1],
                    title: l10n.kniffelSectionLower,
                    sectionTitleStyle: sectionTitleStyle,
                  ),
                  SectionCard(
                    child: Column(
                      children: [
                        for (final field in _lowerFields)
                          _buildRow(field, labelStyle, _labelWidth, chipStyle),
                      ]
                    )
                  ),
                  SectionTitle(
                    key: _sectionKeys[2],
                    title: l10n.kniffelSectionTotals,
                    sectionTitleStyle: sectionTitleStyle,
                  ),
                  SectionCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _labelWidth,
                          child: Column(
                            children: [
                              for (final total in KniffelTotal.values)
                                SizedBox(
                                  height: KniffelLayout.totalsRowHeight, 
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      total.label(l10n),
                                      style: total.isEmphasized
                                          ? emphasizedStyle
                                          : labelStyle,
                                      ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ScrollableColumns(
                            controller: _totalsController, 
                            child: ColumnsRow(
                              count: _players.length,
                              cellBuilder: (_) => Column(
                                children: [
                                  for (final _ in KniffelTotal.values)
                                    const SizedBox(
                                      height: KniffelLayout.totalsRowHeight,
                                      child: Center(child: Text('0')), // Dummy
                                    )
                                ]
                              )
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: KniffelLayout.bottomSpacing,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PinnedHeader(
                controller: _headerController,
                players: _players,
                labelWidth: _labelWidth,
                titleArea: SectionTitleSwitcher(
                  scrollController: _verticalController,
                  viewportKey: _viewportKey,
                  sectionKeys: _sectionKeys,
                  titles: [l10n.kniffelSectionUpper, l10n.kniffelSectionLower, l10n.kniffelSectionTotals],
                  style: sectionTitleStyle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                offset: padOpen ? Offset.zero : const Offset(0, 1),
                child: NumPad(
                  height: KniffelLayout.numPadHeight,
                  topRowHeight: KniffelLayout.numPadTopRowHeight,
                  title: _activeCell?.$1.label(l10n) ?? '',
                  onDigit: _onDigit,
                  onEnter: _onEnter,
                  onCollapse: _deactivate,
                  onDelete: _onDelete,
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(KniffelField field, TextStyle labelStyle, double labelWidth, TextStyle chipStyle) {
    return SheetRow(
      key: _rowKeys[field],
      field: field,
      controller: _rowControllers[field.index], // 1 Controller pro Feld
      playerCount: _players.length,
      cellFor: (player) => _cellFor(field, player),
      onScore: (player, value) => _setValue(field, player, value),
      onCross: (player) => _crossOut(field, player),
      onSelect: (player) => _toggleSelector(field, player),
      activePlayer: _activeCell?.$1 == field ? _activeCell!.$2 : null,
      labelWidth: labelWidth,
      labelStyle: labelStyle,
      chipStyle: chipStyle,
      onActivate: (player) => _activate(field, player),
      inputBuffer: _inputBuffer,
      activeChipKey: _activeChipKey
    );
  }
}