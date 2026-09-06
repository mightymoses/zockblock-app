import 'package:flutter_riverpod/flutter_riverpod.dart';
// ProviderException liegt nicht im Haupt-Export von flutter_riverpod.
import 'package:flutter_riverpod/misc.dart';
import 'package:logger/logger.dart';

/// Protokolliert fehlgeschlagene Provider zentral.
///
/// Bewusst nur Fehler: jede Zustandsänderung mitzuschreiben erzeugt Rauschen,
/// in dem echte Probleme untergehen. In `main.dart` am [ProviderScope]
/// registriert.
final class AppProviderObserver extends ProviderObserver {
  /// Erstellt den Observer mit dem [Logger], in den er schreibt.
  const AppProviderObserver(this._logger);

  final Logger _logger;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    // Hängt ein Provider an einem gescheiterten anderen, meldet Riverpod den
    // Fehler ein zweites Mal - dann aber verpackt. Nur das Original loggen.
    if (error is ProviderException) return;

    _logger.e(
      'Provider fehlgeschlagen: ${context.provider.name ?? context.provider}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
