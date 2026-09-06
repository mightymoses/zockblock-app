import 'package:shared_preferences/shared_preferences.dart';

/// Entscheidung des Nutzers über das Senden von Absturzberichten.
enum CrashReportConsent {
  /// Noch nicht gefragt – der Einwilligungs-Dialog steht aus.
  notAsked,

  /// Zugestimmt, Berichte dürfen gesendet werden.
  granted,

  /// Abgelehnt, es wird nichts gesendet.
  denied,
}

/// Liest und schreibt die Einwilligung dauerhaft auf dem Gerät.
///
/// Bewusst ohne Repository-Interface, anders als `core/auth` und `core/user`:
/// hier wird ein einzelner Schlüssel gelesen und geschrieben, und für Tests
/// genügt `SharedPreferencesAsync.setMockInitialValues()`.
class CrashReportConsentStore {
  /// Erstellt den Speicher.
  const CrashReportConsentStore();

  static const _key = 'crash_report_consent';

  /// Liefert die gespeicherte Entscheidung, [CrashReportConsent.notAsked]
  /// wenn noch keine getroffen wurde.
  Future<CrashReportConsent> read() async {
    final stored = await SharedPreferencesAsync().getString(_key);

    return CrashReportConsent.values
            .where((value) => value.name == stored)
            .firstOrNull ??
        CrashReportConsent.notAsked;
  }

  /// Speichert die Entscheidung des Nutzers.
  Future<void> write(CrashReportConsent consent) {
    return SharedPreferencesAsync().setString(_key, consent.name);
  }
}
