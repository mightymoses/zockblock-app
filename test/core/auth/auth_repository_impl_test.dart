import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zockblock_app/core/auth/auth_repository_impl.dart';
import 'package:zockblock_app/core/auth/auth_service.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockCredentials extends Mock implements Credentials {}

class _MockUserProfile extends Mock implements UserProfile {}

/// Echte Ausnahmen statt Mocks: die Unterscheidung haengt an den
/// `code`-Strings, die das Auth0-SDK liefert. Ein Mock mit gesetzten Gettern
/// wuerde genau die Zuordnung ueberspringen, um die es hier geht.
CredentialsManagerException _exception(String code) {
  return CredentialsManagerException(code, 'Testfall', const {});
}

void main() {
  late _MockAuthService service;
  late AuthRepositoryImpl repository;
  late _MockCredentials credentials;

  setUp(() {
    service = _MockAuthService();
    repository = AuthRepositoryImpl(service);

    final profile = _MockUserProfile();
    when(() => profile.sub).thenReturn('auth0|1');

    credentials = _MockCredentials();
    when(() => credentials.user).thenReturn(profile);
    when(() => credentials.accessToken).thenReturn('token');
  });

  group('getExistingSession', () {
    test('baut eine Session aus den Credentials', () async {
      when(service.getCredentials).thenAnswer((_) async => credentials);

      final session = await repository.getExistingSession();

      expect(session?.externalAuthId, 'auth0|1');
      expect(session?.accessToken, 'token');
    });

    test('liefert null, wenn niemand angemeldet ist', () async {
      // Kein Fehler, sondern der normale Zustand vor dem ersten Login.
      for (final code in ['NO_CREDENTIALS', 'NO_REFRESH_TOKEN']) {
        when(
          service.getCredentials,
        ).thenAnswer((_) async => throw _exception(code));

        expect(
          await repository.getExistingSession(),
          isNull,
          reason: 'bei $code',
        );
      }
    });

    test('wirft weiter, wenn die Erneuerung scheitert', () async {
      // Hier war jemand angemeldet und der Token liess sich nicht erneuern.
      // Wuerde das zu null, saehe es aus wie "nie angemeldet gewesen" - der
      // Nutzer waere still ausgeloggt, ohne zu erfahren warum.
      when(
        service.getCredentials,
      ).thenAnswer((_) async => throw _exception('RENEW_FAILED'));

      await expectLater(
        repository.getExistingSession(),
        throwsA(isA<CredentialsManagerException>()),
      );
    });

    test('wirft unbekannte Codes weiter', () async {
      when(
        service.getCredentials,
      ).thenAnswer((_) async => throw _exception('SOMETHING_ELSE'));

      await expectLater(
        repository.getExistingSession(),
        throwsA(isA<CredentialsManagerException>()),
      );
    });
  });

  test('login baut eine Session aus den Credentials', () async {
    when(service.login).thenAnswer((_) async => credentials);

    final session = await repository.login();

    expect(session.externalAuthId, 'auth0|1');
    expect(session.accessToken, 'token');
  });

  test('logout reicht an den Service durch', () async {
    when(service.logout).thenAnswer((_) async {});

    await repository.logout();

    verify(service.logout).called(1);
  });
}
