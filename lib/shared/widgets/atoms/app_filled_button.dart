import 'package:flutter/material.dart';

/// Flächiger Primär-Button im monochromen Zockblock-Look.
///
/// Farben und Schrift sind bewusst fest verdrahtet statt aus dem Theme
/// abgeleitet, solange nicht entschieden ist, ob die App bei Material-3-
/// Dynamic-Colors bleibt. Diese Datei ist dann die einzige Stelle, die sich
/// dafür ändern muss.
class AppFilledButton extends StatelessWidget {
  /// Erstellt den Button; bei [isLoading] ersetzt ein Spinner das [label] und
  /// der Button ist gesperrt.
  const AppFilledButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  /// Beschriftung des Buttons.
  final String label;

  /// Wird beim Antippen aufgerufen; `null` sperrt den Button.
  final VoidCallback? onPressed;

  /// Ob gerade eine Aktion läuft und statt [label] ein Spinner erscheint.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.white,
        disabledForegroundColor: Colors.black,
        minimumSize: const Size.fromHeight(50),
        shape: const RoundedRectangleBorder(),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 4,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontFamily: 'ComradeBold', fontSize: 22),
            ),
    );
  }
}
