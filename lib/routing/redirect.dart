import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/auth/auth_session.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';
import 'package:zockblock_app/core/user/user.dart';

/// Entscheidet anhand der drei Gates, wohin umgeleitet wird; `null` heißt
/// "bleiben, wo man ist".
///
/// Bewusst eine reine Funktion und keine Closure im `GoRouter`-Konstruktor:
/// so ist die verzweigteste Logik der App ohne Router und ohne durchgespielte
/// Navigation testbar.
///
/// Ein noch ladender Provider führt nie zu einer Umleitung – sonst würde beim
/// Start kurz die falsche Seite aufblitzen.
String? resolveRedirect({
  required AsyncValue<CrashReportConsent> consent,
  required AsyncValue<AuthSession?> authSession,
  required AsyncValue<User?> user,
  required String location,
}) {
  final consentValue = consent.value;
  final onConsentPage = location == '/consent';

  // Vor allem anderen: solange die Einwilligung aussteht, wird nur gefragt.
  if (consentValue == CrashReportConsent.notAsked) {
    return onConsentPage ? null : '/consent';
  }
  if (consentValue != null && onConsentPage) {
    // Beantwortet - weiter zur Auth-Kette, die über das Ziel entscheidet.
    return '/';
  }

  return authSession.when(
    data: (session) {
      if (session == null) {
        return '/auth';
      }

      return user.when(
        data: (currentUser) {
          if (currentUser == null) {
            return '/profile-setup';
          }

          if (location == '/auth' || location == '/profile-setup') {
            return '/';
          }

          return null;
        },
        loading: () => null,
        // Echter Fehler (z.B. Netzwerk) - nicht erzwungen zu /profile-setup
        // navigieren, sonst würde ein bereits eingerichteter Nutzer bei einem
        // Wackler dorthin verschoben.
        error: (_, _) => null,
      );
    },
    loading: () => null,
    error: (_, _) => '/auth',
  );
}
