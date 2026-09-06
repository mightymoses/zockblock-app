import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ProviderException liegt nicht im Haupt-Export von flutter_riverpod.
import 'package:flutter_riverpod/misc.dart';
import 'package:logger/logger.dart';

/// Protokolliert fehlgeschlagene Provider zentral – lokal im Log und, sofern
/// eingewilligt, als Bericht in Crashlytics.
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

    final description =
        'Provider fehlgeschlagen: '
        '${context.provider.name ?? context.provider}';

    _logger.e(description, error: error, stackTrace: stackTrace);

    // `fatal` bleibt beim Default false: die App läuft weiter, der Fehler
    // steckt im Provider-State und wird von der UI angezeigt. Ob überhaupt
    // gesendet wird, hängt an der Einwilligung (`crashReportingProvider`).
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: description,
      ),
    );
  }
}
