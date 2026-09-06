import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';

/// Stellt den [CrashReportConsentStore] bereit.
final crashReportConsentStoreProvider = Provider<CrashReportConsentStore>(
  (ref) => const CrashReportConsentStore(),
);

/// Einwilligung in Absturzberichte; steuert das Auth-/Profil-Gate im Router
/// mit, weil vor der Entscheidung nichts anderes angezeigt wird.
final AsyncNotifierProvider<CrashReportConsentNotifier, CrashReportConsent>
crashReportConsentProvider = AsyncNotifierProvider(
  CrashReportConsentNotifier.new,
);

/// Hält die Einwilligung und schreibt Änderungen dauerhaft weg.
class CrashReportConsentNotifier extends AsyncNotifier<CrashReportConsent> {
  @override
  FutureOr<CrashReportConsent> build() {
    return ref.watch(crashReportConsentStoreProvider).read();
  }

  /// Der Nutzer erlaubt das Senden von Absturzberichten.
  Future<void> grant() => _save(CrashReportConsent.granted);

  /// Der Nutzer lehnt das Senden von Absturzberichten ab.
  Future<void> deny() => _save(CrashReportConsent.denied);

  Future<void> _save(CrashReportConsent consent) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(crashReportConsentStoreProvider).write(consent);
      return consent;
    });
  }
}
