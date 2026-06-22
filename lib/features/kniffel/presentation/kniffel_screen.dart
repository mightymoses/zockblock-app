import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

import '../domain/kniffel_field.dart';
import '../domain/kniffel_total.dart';
import '../domain/kniffel_cell.dart';
import 'support/kniffel_scroll_coordinator.dart';
import 'widgets/kniffel_expansion_row.dart';
import 'support/kniffel_field_labels.dart';
import 'support/kniffel_layout.dart';
import 'widgets/kniffel_totals_section.dart';
import 'widgets/kniffel_num_pad.dart';
import 'widgets/kniffel_pinned_header.dart';
import 'widgets/kniffel_section_title.dart';
import 'widgets/kniffel_section_title_switcher.dart';
import 'widgets/kniffel_sheet_row.dart';
import 'widgets/kniffel_section_card.dart';
import 'support/measure_max_text_width.dart';

class KniffelScreen extends StatefulWidget {
  const KniffelScreen({super.key});

  @override
  State<KniffelScreen> createState() => _KniffelScreenState();
}

class _KniffelScreenState extends State<KniffelScreen> {
  static final _upperFields = KniffelField.values.where((f) => f.isUpper).toList();
  static final _lowerFields = KniffelField.values.where((f) => !f.isUpper).toList();
  static const _players = ['Moritz', 'Lisa', 'Tim', 'Anna', 'Max', 'Sophie'];
  final _sectionKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
  double _labelWidth = 0;
  (KniffelField, int player)? _activeCell;
  final Map<(KniffelField, int player), KniffelCell> _cells = {};
  String _inputBuffer = '';
  double get _padTotalHeight => KniffelLayout.numPadHeight + MediaQuery.viewPaddingOf(context).bottom;
  late final KniffelScrollCoordinator _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = KniffelScrollCoordinator();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _activate(KniffelField field, int player) {
    _scroll.safe();
    setState(() {
      _activeCell = (field, player);
      _inputBuffer = '';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll.scrollIntoView(field: field, padTotalHeight: _padTotalHeight, labelWidth: _labelWidth);
    });
  }

  void _deactivate() {
    setState(() {
      _activeCell = null;
      _inputBuffer = '';
    });
    _scroll.restore(isStillActive: () => _activeCell != null);
  }

  void _setValue(KniffelField field, int player, int value) {
    setState(() {
      _cells[(field, player)] = ScoredCell(value);
      _activeCell = null;
      _inputBuffer = '';
    });
    _scroll.restore(isStillActive: () => _activeCell != null);
  }

  void _crossOut(KniffelField field, int player) {
    setState(() {
      _cells[(field, player)] = const CrossedCell();
      _activeCell = null;
    });
    _scroll.restore(isStillActive: () => _activeCell != null);
  }

  void _onDigit(int d) {
    if (_inputBuffer.length >= 2) return;
    setState(() => _inputBuffer += '$d');
    _scroll.scrollIntoView(field: _activeCell!.$1, padTotalHeight: _padTotalHeight, labelWidth: _labelWidth);
  }

  void _onDelete() {
    if (_inputBuffer.isEmpty) return;
    setState(() => _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1));
    _scroll.scrollIntoView(field: _activeCell!.$1, padTotalHeight: _padTotalHeight, labelWidth: _labelWidth);
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

  void _toggleSelector(KniffelField field, int player) {
    final target = (field, player);
    setState(() {
      _activeCell = (_activeCell == target) ? null : target;
    });
    if (_activeCell == null) {
      _scroll.restore(isStillActive: () => _activeCell != null);
    }
  }
  
  KniffelCell _cellFor(KniffelField field, int player) {
    return _cells[(field, player)] ?? const EmptyCell();
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
              key: _scroll.viewportKey,
              controller: _scroll.verticalController,
              padding: EdgeInsets.only(
                bottom: padOpen ? _padTotalHeight : 0
              ),
              child: Column(
                children: [
                  KniffelSectionTitle(
                    key: _sectionKeys[0],
                    title: l10n.kniffelSectionUpper,
                    sectionTitleStyle: sectionTitleStyle,
                  ),
                  _buildUpperSection(
                    labelStyle,
                    chipStyle
                  ),
                  KniffelSectionTitle(
                    key: _sectionKeys[1],
                    title: l10n.kniffelSectionLower,
                    sectionTitleStyle: sectionTitleStyle,
                  ),
                  KniffelSectionCard(
                    child: Column(
                      children: [
                        for (final field in _lowerFields)
                          _buildRow(field, labelStyle, _labelWidth, chipStyle),
                      ]
                    )
                  ),
                  KniffelSectionTitle(
                    key: _sectionKeys[2],
                    title: l10n.kniffelSectionTotals,
                    sectionTitleStyle: sectionTitleStyle,
                  ),
                  KniffelTotalsSection(
                    labelWidth: _labelWidth,
                    labelStyle: labelStyle,
                    emphasizedStyle: emphasizedStyle,
                    players: _players,
                    totalsController: _scroll.totalsController,
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
              child: KniffelPinnedHeader(
                controller: _scroll.headerController,
                players: _players,
                labelWidth: _labelWidth,
                titleArea: KniffelSectionTitleSwitcher(
                  scrollController: _scroll.verticalController,
                  viewportKey: _scroll.viewportKey,
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
                child: KniffelNumPad(
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
    return KniffelSheetRow(
      key: _scroll.rowKeys[field],
      field: field,
      controller: _scroll.rowController(field), // 1 Controller pro Feld
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
      activeChipKey: _scroll.activeChipKey
    );
  }

  Widget _buildUpperSection(TextStyle labelStyle, TextStyle chipStyle) {
    return KniffelSectionCard(
      child: Column(
        children: [
          for (final field in _upperFields) ...[
            _buildRow(field, labelStyle, _labelWidth, chipStyle),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _activeCell?.$1 == field
                  ? KniffelExpansionRow(
                      values: field.selectorValues!,
                      onValueSelected: (value) => _setValue(field, _activeCell!.$2, value),
                      chipStyle: chipStyle,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ]
      )
    );
  }
}