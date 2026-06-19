import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../kniffel_cell.dart';
import '../kniffel_field.dart';
import 'chip_shell.dart';
import 'kniffel_cell_content.dart';
import 'kniffel_layout.dart';
import 'measure_max_text_width.dart';

class KniffelInputChip extends StatefulWidget {
  const KniffelInputChip({
    super.key,
    required this.field,
    required this.cell,
    required this.isActive,        // NEU: aus _activeCell
    required this.onActivate,      // NEU: Tap → Screen aktiviert
    required this.onScore,         // Commit: Screen setzt Wert + deaktiviert
    required this.onCancel,        // NEU: Zurück/ungültig → deaktivieren ohne Wert
    required this.onCross,
    required this.onEditStart,
    required this.onEditEnd,
    required this.textStyle,
  });

  final KniffelField field;
  final KniffelCell cell;
  final bool isActive;
  final VoidCallback onActivate;
  final ValueChanged<int> onScore;
  final VoidCallback onCancel;
  final VoidCallback onCross;
  final VoidCallback onEditStart;
  final VoidCallback onEditEnd;
  final TextStyle textStyle;

  @override
  State<KniffelInputChip> createState() => _KniffelInputChipState();
}

class _KniffelInputChipState extends State<KniffelInputChip>
    with WidgetsBindingObserver {
  bool _keyboardWasOpen = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onActivated() {
    _controller.clear();
    _keyboardWasOpen = false;
    widget.onEditStart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isActive) _focusNode.requestFocus();
    });
  }

  void _onDeactivated() {
    // Verwerfen: nur lokal aufräumen, NICHT committen.
    widget.onEditEnd();
    _focusNode.unfocus();
    _controller.clear();
  }

  @override
  void didUpdateWidget(KniffelInputChip old) {
    super.didUpdateWidget(old);
    if (!old.isActive && widget.isActive) {
      _onActivated();
    } else if (old.isActive && !widget.isActive) {
      _onDeactivated();
    }
  }

  @override
  void didChangeMetrics() {
    if (!widget.isActive) return;
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;
    if (keyboardOpen) {
      _keyboardWasOpen = true;
    } else if (_keyboardWasOpen) {
      widget.onCancel(); // Zurück-Taste → deaktivieren (verwerfen)
    }
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value != null && widget.field.isValidManualValue(value)) {
      widget.onScore(value); // Screen setzt Wert + deaktiviert
    } else {
      widget.onCancel();     // ungültig/leer → verwerfen
    }
  }

  // void _restoreScroll() {
  //   final primary = FocusManager.instance.primaryFocus;
  //   if (primary != null && primary is! FocusScopeNode) return;

  //   final offset = _savedOffset;
  //   _savedOffset = null;
  //   if (offset == null || !widget.verticalController.hasClients) return;
  //   widget.verticalController.animateTo(
  //     offset,
  //     duration: const Duration(milliseconds: 200),
  //     curve: Curves.easeOut,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ChipShell(
      onTap: widget.cell.isEmpty && !widget.isActive ? widget.onActivate : null,
      onLongPress: (widget.field.canCross && widget.cell.isEmpty && !widget.isActive)
          ? widget.onCross
          : null,
      isActive: widget.isActive,
      child: widget.isActive
          ? _buildField()
          : KniffelCellContent(widget.cell, style: widget.textStyle),
    );
  }

  Widget _buildField() {
    final textWidth = measureMaxTextWidth(context, [_controller.text], widget.textStyle);
    return TextField(
      scrollPadding: EdgeInsets.symmetric(
        horizontal: KniffelLayout.columnWidth / 2 - textWidth / 2,
        vertical: 20,
      ),
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.center,
      style: widget.textStyle,
      cursorWidth: 0,
      enableInteractiveSelection: false,
      selectionControls: null,
      keyboardType: TextInputType.number,
      onSubmitted: (_) => _submit(),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
    );
  }
}