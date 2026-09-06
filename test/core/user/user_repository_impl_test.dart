import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/core/user/user_repository_impl.dart';
import 'package:zockblock_app/core/user/user_service.dart';

class _MockUserService extends Mock implements UserService {}

// Fehler werden ueber `thenAnswer((_) async => throw ...)` gemeldet, nicht
// ueber `thenThrow`: ein echter dio-Aufruf wirft asynchron. Mit `thenThrow`
// flogen die Ausnahmen synchron aus dem Aufruf heraus, was `createUser`
// (gibt den Future direkt weiter) anders behandelt als die Realitaet.

void main() {
  late _MockUserService service;
  late UserRepositoryImpl repository;

  const user = User(username: 'mightymoses', id: '1');

  setUp(() {
    service = _MockUserService();
    repository = UserRepositoryImpl(service);
  });

  setUpAll(() {
    registerFallbackValue(const User(username: 'fallback'));
  });

  group('getCurrentUser', () {
    test('reicht das Profil durch', () async {
      when(service.getCurrentUser).thenAnswer((_) async => user);

      expect(await repository.getCurrentUser(), user);
    });

    test('macht aus NotFound ein null - kein Profil ist kein Fehler', () async {
      when(service.getCurrentUser).thenAnswer(
        (_) async => throw const NotFoundException(),
      );

      expect(await repository.getCurrentUser(), isNull);
    });

    test('wirft alles andere weiter', () async {
      // Wuerde das hier zu null, waere "Backend kaputt" von "noch kein
      // Profil" nicht mehr unterscheidbar - und der Nutzer landete im
      // Profil-Setup, obwohl er laengst eines hat.
      const failures = <AppException>[
        NetworkException(),
        ServerException(),
        UnauthorizedException(),
        UnknownException(),
      ];

      for (final failure in failures) {
        when(service.getCurrentUser).thenAnswer((_) async => throw failure);

        await expectLater(
          repository.getCurrentUser(),
          throwsA(same(failure)),
          reason: 'bei ${failure.runtimeType}',
        );
      }
    });
  });

  group('createUser', () {
    test('reicht das angelegte Profil durch', () async {
      when(() => service.createUser(any())).thenAnswer((_) async => user);

      expect(await repository.createUser(const User(username: 'neu')), user);
    });

    test('schluckt keine Fehler', () async {
      // Vor dem Fix in Punkt B wurde hier gefangen und null geliefert, und
      // das Formular meldete Erfolg, obwohl nichts angelegt wurde.
      when(
        () => service.createUser(any()),
      ).thenAnswer((_) async => throw const ServerException());

      await expectLater(
        repository.createUser(const User(username: 'neu')),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
