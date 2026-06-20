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

  (KniffelField, int player)? _activeCell;

  void _activate(KniffelField field, int player) {
    setState(() {
      _activeCell = (field, player);
      _inputBuffer = '';
    });
  }

  void _deactivate() => setState(() => _activeCell = null);

  void _toggleSelector(KniffelField field, int player) {
    setState(() {
      final target = (field, player);
      _activeCell = (_activeCell == target) ? null : target;
    });
  }

  void _setValue(KniffelField field, int player, int value) {
    setState(() {
      _cells[(field, player)] = ScoredCell(value);
      _activeCell = null;
    });
  }

  void _crossOut(KniffelField field, int player) {
    setState(() {
      _cells[(field, player)] = const CrossedCell();
      _activeCell = null;
    });
  }

  final Map<(KniffelField, int player), KniffelCell> _cells = {};
  KniffelCell _cellFor(KniffelField field, int player) =>
    _cells[(field, player)] ?? const EmptyCell();

  double? _savedScrollOffset;

  String _inputBuffer = '';

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

  void _onEditStart() {
    _savedScrollOffset ??= _verticalController.offset;
  }

  void _onEditEnd() {
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
  }

  void _onDelete() {
    if (_inputBuffer.isEmpty) return;
    setState(() => _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyLarge!;
    final emphasizedStyle = labelStyle.copyWith(fontWeight: FontWeight.bold);
    final sectionTitleStyle = theme.textTheme.titleMedium!;
    final chipStyle = theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    final labelWidth = [
        measureMaxTextWidth(context,
            [for (final f in KniffelField.values) f.label(l10n)], labelStyle),
        measureMaxTextWidth(context,
            [for (final t in KniffelTotal.values) t.label(l10n)], emphasizedStyle),
        measureMaxTextWidth(context,
            [l10n.kniffelSectionUpper, l10n.kniffelSectionLower, l10n.kniffelSectionTotals],
            sectionTitleStyle),
      ].reduce(max) + KniffelLayout.labelToChipSpacing;

    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: Stack(
        children: [
          SingleChildScrollView(
            key: _viewportKey,
            controller: _verticalController,
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
                        _buildRow(field, labelStyle, labelWidth, chipStyle),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: _activeCell?.$1 == field
                              ? ExpansionRow(
                                  values: field.selectorValues!,
                                  onValueSelected: (value) => _setValue(field, _activeCell!.$2, value),
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
                        _buildRow(field, labelStyle, labelWidth, chipStyle),
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
                        width: labelWidth,
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
              labelWidth: labelWidth,
              titleArea: SectionTitleSwitcher(
                scrollController: _verticalController,
                viewportKey: _viewportKey,
                sectionKeys: _sectionKeys,
                titles: [l10n.kniffelSectionUpper, l10n.kniffelSectionLower, l10n.kniffelSectionTotals],
                style: sectionTitleStyle,
              ),
            ),
          ),
          if (_activeCell != null && _activeCell!.$1.chipKind == ChipKind.manualInput)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NumPad(
                height: KniffelLayout.numPadHeight,
                topRowHeight: KniffelLayout.numPadTopRowHeight,
                title: _activeCell!.$1.label(l10n),
                onDigit: _onDigit,
                onEnter: _onEnter,
                onCollapse: _deactivate,
                onDelete: _onDelete,
              )
            )
        ],
      ),
    );
  }

  Widget _buildRow(KniffelField field, TextStyle labelStyle, double labelWidth, TextStyle chipStyle) {
    return SheetRow(
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
    );
  }
}