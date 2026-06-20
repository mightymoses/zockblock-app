import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zockblock_app/core/theme/app_dimensions.dart';

class NumPad extends StatelessWidget {
  const NumPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onCollapse,
    required this.onEnter,
    required this.height,
    required this.topRowHeight,
    this.title,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onCollapse;
  final VoidCallback onEnter;
  final double height;
  final double topRowHeight;
  final String? title;

  @override
  Widget build(BuildContext context) {
    
    final rows = <List<_KeySpec>>[
      [_DigitKey(1), _DigitKey(2), _DigitKey(3)],
      [_DigitKey(4), _DigitKey(5), _DigitKey(6)],
      [_DigitKey(7), _DigitKey(8), _DigitKey(9)],
      [_ActionKey(Icons.keyboard_hide, onCollapse), _DigitKey(0), _ActionKey(Icons.backspace, onDelete)],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: AppRadius.sm,
            offset: const Offset(0, -2),
          )
        ]
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: SizedBox(
                  height: topRowHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    child: Row(
                      children: [
                        if (title != null) Text(title!, style: Theme.of(context).textTheme.titleMedium),
                        Spacer(),
                        _EnterButton(onPressed: onEnter)
                    ]
                    ),
                  )
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final row in rows)
                        Expanded(
                          child: Row(
                            spacing: AppSpacing.sm,
                            children: [
                              for (final key in row)
                                Expanded(
                                  child: switch (key) {
                                    _DigitKey(:final digit) => _KeyButton.digit(digit: digit, onTap: () => onDigit(digit)),
                                    _ActionKey(:final icon, :final onPressed) => _KeyButton.action(icon: icon, onTap: onPressed)
                                  }
                                )
                            ]
                          )
                        )
                    ]
                  )
                )
              )
            ]
          )
        )
      ),
    );
  }
}

sealed class _KeySpec {
  const _KeySpec();
}

class _DigitKey extends _KeySpec {
  final int digit;

  const _DigitKey(this.digit);
}

class _ActionKey extends _KeySpec {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionKey(this.icon, this.onPressed);
}

class _KeyButton extends StatelessWidget {
  const _KeyButton.digit({
    required this.digit,
    required this.onTap
  }): icon = null;

  const _KeyButton.action({
    required this.icon,
    required this.onTap
  }): digit = null;

  final VoidCallback onTap;
  final IconData? icon;
  final int? digit;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(AppRadius.sm);

    return Material(
      color: icon != null ? Theme.of(context).colorScheme.surfaceContainerHigh : Theme.of(context).colorScheme.surfaceContainerLowest,
      elevation: icon != null ? 0 : 1,
      surfaceTintColor: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: borderRadius,
        child: Center(
          child: icon != null ? Icon(icon) : Text(digit!.toString(), style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}

class _EnterButton extends StatefulWidget {
  const _EnterButton({
    required this.onPressed
  });

  final VoidCallback onPressed;

  @override
  State<_EnterButton> createState() => _EnterButtonState();
}

class _EnterButtonState extends State<_EnterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 100),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: _isPressed ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6) : Theme.of(context).colorScheme.primary,
            fontWeight: _isPressed ? FontWeight.w900 : FontWeight.w600
          ),
          child: const Text('Eintragen') // TODO
        )
      )
    );
  }
}