import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/shared/widgets/molecules/error_view.dart';

/// Rendert einen [AsyncValue] einheitlich als Inhalt, Ladeanzeige oder Fehler.
///
/// Ersetzt Konstrukte wie `maybeWhen(orElse: SizedBox.shrink)`, bei denen ein
/// Fehler als leere Fläche endet und der Nutzer nicht erfährt, was los ist.
/// Liegt bereits ein Wert vor, bleibt er bei Refresh und Fehler stehen, statt
/// wegzuspringen.
class AsyncValueView<T> extends StatelessWidget {
  /// Erstellt die Anzeige für [value].
  const AsyncValueView({
    required this.value,
    required this.data,
    super.key,
    this.onRetry,
  });

  /// Der darzustellende Zustand.
  final AsyncValue<T> value;

  /// Baut die Darstellung des geladenen Werts.
  final Widget Function(T value) data;

  /// Wird dem Wiederholen-Button im Fehlerfall übergeben.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) {
      return data(value.requireValue);
    }
    if (value.hasError) {
      return ErrorView(
        error: value.error!,
        onRetry: onRetry,
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
