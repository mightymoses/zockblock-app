import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Erzeugt den Logger der App.
///
/// Der Default-Filter von `logger` (`DevelopmentFilter`) unterdrückt im
/// Release-Build *alle* Ausgaben – das ist so gewollt: Logzeilen auf einem
/// fremden Gerät liest niemand. Für Produktion übernimmt das Crash-Reporting.
Logger createAppLogger() {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}

/// Logger der App.
///
/// `main.dart` überschreibt ihn mit derselben Instanz, die auch der
/// ProviderObserver benutzt – der existiert vor dem Container und kann ihn
/// daher nicht von hier beziehen.
final loggerProvider = Provider<Logger>((ref) => createAppLogger());
