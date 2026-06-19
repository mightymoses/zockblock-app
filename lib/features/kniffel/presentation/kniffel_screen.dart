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
import 'pinned_header.dart';
import 'scrollable_columns.dart';
import 'section_title.dart';
import 'sheet_row.dart';
import 'section_card.dart';

/// Gerüst für den Kniffel-Scoresheet-Screen.
/// Nur Layout + Scroll-Sync, alles Dummy: keine echten Chips, kein State.
class KniffelScreen extends StatefulWidget {
  const KniffelScreen({super.key});

  @override
  State<KniffelScreen> createState() => _KniffelScreenState();
}

class _KniffelScreenState extends State<KniffelScreen> {
  static final _upperFields = KniffelField.values.where((f) => f.isUpper).toList();
  static final _lowerFields = KniffelField.values.where((f) => !f.isUpper).toList();
  
  // --- Dummy-Daten -------------------------------------------------------
  static const _players = ['Moritz', 'Lisa', 'Tim', 'Anna', 'Max', 'Sophie'];

  // --- Scroll-Sync -------------------------------------------------------
  final _scrollGroup = LinkedScrollControllerGroup();
  late final ScrollController _headerController;
  late final List<ScrollController> _rowControllers;
  late final ScrollController _totalsController;
  final _verticalController = ScrollController();

  int get _rowCount => _upperFields.length + _lowerFields.length;

  (KniffelField, int player)? _activeCell;

  void _activate(KniffelField field, int player) =>
    setState(() => _activeCell = (field, player));

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
    // Nur beim ersten Feld merken – bei Wechsel nicht überschreiben.
    _savedScrollOffset ??= _verticalController.offset;
  }

  void _onEditEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_activeCell != null) return; // noch was aktiv (Wechsel) → nicht zurückscrollen
      final offset = _savedScrollOffset;
      _savedScrollOffset = null;
      if (offset == null || !_verticalController.hasClients) return;
      _verticalController.animateTo(offset,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
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
      ].reduce(max) + KniffelLayout.labelPadding + 32; // TODO: Mit der 32 rumspielen (Und dann im Layout als Kontante festlegen)

    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: Column(
        children: [
          PinnedHeader(
            // TODO: Titel später dynamisch aus vertikalem Scroll-Offset.
            title: l10n.kniffelSectionUpper,
            controller: _headerController,
            players: _players,
            labelWidth: labelWidth,
            sectionTitleStyle: sectionTitleStyle,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _verticalController,
              child: Column(
                children: [
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
                  SectionCard(
                    title: l10n.kniffelSectionLower,
                    titleStyle: sectionTitleStyle,
                    child: Column(
                      children: [
                        for (final field in _lowerFields)
                          _buildRow(field, labelStyle, labelWidth, chipStyle),
                      ]
                    )
                  ),
                  SectionCard(
                    title: l10n.kniffelSectionTotals,
                    titleStyle: sectionTitleStyle,
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: KniffelLayout.labelPadding),
                                      child: Text(
                                        total.label(l10n),
                                        style: total.isEmphasized
                                            ? emphasizedStyle
                                            : labelStyle,
                                        ),
                                    )
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
                ],
              ),
            ),
          ),
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
      onEditStart: _onEditStart,
      onEditEnd: _onEditEnd,
      activePlayer: _activeCell?.$1 == field ? _activeCell!.$2 : null,
      labelWidth: labelWidth,
      labelStyle: labelStyle,
      chipStyle: chipStyle,
      onActivate: (player) => _activate(field, player),
      onCancel: _deactivate,
    );
  }
}