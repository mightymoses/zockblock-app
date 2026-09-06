import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` liegt nicht im Haupt-Export von flutter_riverpod.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

/// Rahmen für Widget-Tests: `ProviderScope` plus eine `MaterialApp` mit den
/// Lokalisierungs-Delegates.
extension PumpApp on WidgetTester {
  /// Zeichnet [widget] mit allem, was Sections und Molecules erwarten.
  ///
  /// Die Locale ist fest auf Deutsch, damit Erwartungen im Test nicht von der
  /// Locale des ausführenden Rechners abhängen. `retry` ist abgeschaltet,
  /// sonst wiederholt `appRetryPolicy` jeden Fehlerfall mit Verzögerung.
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: overrides,
        retry: (_, _) => null,
        child: MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Viele Bausteine setzen einen Scaffold voraus - etwa alles, was
          // eine SnackBar zeigt oder ListTile-Layout benutzt.
          home: Scaffold(body: widget),
        ),
      ),
    );
  }
}
