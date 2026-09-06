import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zockblock_app/core/auth/auth_session.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/routing/redirect.dart';

const _session = AuthSession(externalAuthId: 'auth0|1', accessToken: 'token');
const _user = User(username: 'mightymoses', id: '1');

const AsyncData<CrashReportConsent> _consentAnswered = AsyncData(
  CrashReportConsent.granted,
);
const AsyncData<AuthSession?> _loggedIn = AsyncData(_session);
const AsyncData<User?> _hasProfile = AsyncData(_user);

final AsyncError<Never> _failure = AsyncError(
  Exception('kaputt'),
  StackTrace.empty,
);

/// Ruft [resolveRedirect] auf; nicht gesetzte Gates sind "alles erledigt",
/// damit jeder Test nur das benennt, worum es ihm geht.
String? redirectFrom(
  String location, {
  AsyncValue<CrashReportConsent> consent = _consentAnswered,
  AsyncValue<AuthSession?> authSession = _loggedIn,
  AsyncValue<User?> user = _hasProfile,
}) {
  return resolveRedirect(
    consent: consent,
    authSession: authSession,
    user: user,
    location: location,
  );
}

void main() {
  group('Einwilligungs-Gate', () {
    test('ohne Entscheidung geht es zur Frage', () {
      expect(
        redirectFrom(
          '/',
          consent: const AsyncData(CrashReportConsent.notAsked),
        ),
        '/consent',
      );
    });

    test('auf der Frage selbst wird nicht erneut umgeleitet', () {
      // Ohne diesen Fall dreht go_router in einer Redirect-Schleife.
      expect(
        redirectFrom(
          '/consent',
          consent: const AsyncData(CrashReportConsent.notAsked),
        ),
        isNull,
      );
    });

    test('waehrend des Ladens wird nicht umgeleitet', () {
      // Sonst blitzt die Consent-Seite beim Start kurz auf.
      expect(
        redirectFrom('/', consent: const AsyncLoading<CrashReportConsent>()),
        isNull,
      );
    });

    test('nach der Antwort geht es weg von der Frage', () {
      for (final answer in [
        CrashReportConsent.granted,
        CrashReportConsent.denied,
      ]) {
        expect(
          redirectFrom('/consent', consent: AsyncData(answer)),
          '/',
          reason: 'bei $answer',
        );
      }
    });

    test('ein Lesefehler blockiert die App nicht', () {
      // shared_preferences kaputt: das Gate faellt einfach weg, statt den
      // Nutzer auf der Frage festzuhalten. Crashlytics bleibt dann aus.
      expect(redirectFrom('/', consent: _failure), isNull);
    });
  });

  group('Auth-Gate', () {
    test('ohne Session geht es zum Login', () {
      expect(
        redirectFrom('/', authSession: const AsyncData<AuthSession?>(null)),
        '/auth',
      );
    });

    test('waehrend des Ladens wird nicht umgeleitet', () {
      expect(
        redirectFrom('/', authSession: const AsyncLoading<AuthSession?>()),
        isNull,
      );
    });

    test('bei einem Fehler geht es zum Login', () {
      // Bewusst der sichere Fallback: lieber anmelden lassen als eine
      // ungepruefte Session weiterverwenden.
      expect(redirectFrom('/', authSession: _failure), '/auth');
    });
  });

  group('Profil-Gate', () {
    test('ohne Profil geht es zum Anlegen', () {
      expect(
        redirectFrom('/', user: const AsyncData<User?>(null)),
        '/profile-setup',
      );
    });

    test('waehrend des Ladens wird nicht umgeleitet', () {
      expect(redirectFrom('/', user: const AsyncLoading<User?>()), isNull);
    });

    test('ein Fehler schickt NICHT zum Anlegen', () {
      // Der wichtigste Fall: bei einem Netzwerkwackler wuerde ein laengst
      // eingerichteter Nutzer sonst im Profil-Setup landen.
      expect(redirectFrom('/', user: _failure), isNull);
    });
  });

  group('vollstaendig eingerichtet', () {
    test('kommt von den Gate-Seiten weg', () {
      expect(redirectFrom('/auth'), '/');
      expect(redirectFrom('/profile-setup'), '/');
      expect(redirectFrom('/consent'), '/');
    });

    test('bleibt auf regulaeren Seiten', () {
      expect(redirectFrom('/'), isNull);
      expect(redirectFrom('/user-profile'), isNull);
    });
  });

  group('Reihenfolge der Gates', () {
    test('die Einwilligung kommt vor Login und Profil', () {
      // Nichts darf vor der Frage passieren - auch nicht die Umleitung zum
      // Login, obwohl gar keine Session da ist.
      expect(
        redirectFrom(
          '/',
          consent: const AsyncData(CrashReportConsent.notAsked),
          authSession: const AsyncData<AuthSession?>(null),
          user: const AsyncData<User?>(null),
        ),
        '/consent',
      );
    });

    test('der Login kommt vor dem Profil', () {
      expect(
        redirectFrom(
          '/',
          authSession: const AsyncData<AuthSession?>(null),
          user: const AsyncData<User?>(null),
        ),
        '/auth',
      );
    });
  });
}
