import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/core/user/user_repository.dart';
import 'package:zockblock_app/core/user/user_repository_impl.dart';
import 'package:zockblock_app/features/user_profile/domain/username.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_viewmodel.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late _MockUserRepository repository;

  setUpAll(() => registerFallbackValue(const User(username: 'fallback')));

  setUp(() {
    repository = _MockUserRepository();
    // Ausgangslage der Seite: angemeldet, aber noch kein Profil angelegt.
    when(repository.getCurrentUser).thenAnswer((_) async => null);
  });

  /// Container mit gemocktem Repository. `retry` ist abgeschaltet, sonst
  /// wiederholt `appRetryPolicy` jeden Fehlerfall viermal mit Verzoegerung.
  ProviderContainer createContainer() {
    return ProviderContainer.test(
        overrides: [userRepositoryProvider.overrideWithValue(repository)],
        retry: (_, _) => null,
      )
      // Haelt den autoDispose-Provider am Leben, solange der Test laeuft.
      ..listen(profileSetupViewModelProvider, (_, _) {});
  }

  ProfileSetupViewModel viewModelOf(ProviderContainer container) =>
      container.read(profileSetupViewModelProvider.notifier);

  ProfileSetup stateOf(ProviderContainer container) =>
      container.read(profileSetupViewModelProvider);

  group('Validierung', () {
    test('leerer Name meldet empty und legt nichts an', () async {
      final container = createContainer();

      expect(await viewModelOf(container).submitForm(), isFalse);
      expect(stateOf(container).usernameError, UsernameValidationError.empty);
      expect(stateOf(container).showErrors, isTrue);
      verifyNever(() => repository.createUser(any()));
    });

    test('zu kurzer Name meldet tooShort und legt nichts an', () async {
      final container = createContainer();
      viewModelOf(container).updateUsername('ab');

      expect(await viewModelOf(container).submitForm(), isFalse);
      expect(
        stateOf(container).usernameError,
        UsernameValidationError.tooShort,
      );
      verifyNever(() => repository.createUser(any()));
    });

    test('Tippen blendet den Fehler wieder aus', () async {
      final container = createContainer();
      await viewModelOf(container).submitForm();
      expect(stateOf(container).showErrors, isTrue);

      viewModelOf(container).updateUsername('a');

      // Der Fehler soll waehrend des Tippens verschwinden, nicht erst beim
      // naechsten Absenden.
      expect(stateOf(container).showErrors, isFalse);
    });
  });

  group('Absenden', () {
    test('legt das Profil an und meldet Erfolg', () async {
      const created = User(username: 'mightymoses', id: '1');
      when(
        () => repository.createUser(any()),
      ).thenAnswer((_) async => created);

      final container = createContainer();
      viewModelOf(container).updateUsername('mightymoses');

      expect(await viewModelOf(container).submitForm(), isTrue);
      expect(stateOf(container).hasSubmitError, isFalse);
      expect(stateOf(container).isLoading, isFalse);
      verify(
        () => repository.createUser(const User(username: 'mightymoses')),
      ).called(1);
    });

    test('meldet einen Fehlschlag, statt Erfolg vorzutaeuschen', () async {
      // Der Bug aus Punkt B: hier kam frueher unabhaengig vom Ergebnis true
      // zurueck, und der Nutzer landete auf einer Seite ohne Profil.
      when(
        () => repository.createUser(any()),
      ).thenAnswer((_) async => throw const ServerException());

      final container = createContainer();
      viewModelOf(container).updateUsername('mightymoses');

      expect(await viewModelOf(container).submitForm(), isFalse);
      expect(stateOf(container).hasSubmitError, isTrue);
      expect(stateOf(container).isLoading, isFalse);
    });

    test('ein neuer Versuch raeumt den alten Fehler weg', () async {
      when(
        () => repository.createUser(any()),
      ).thenAnswer((_) async => throw const ServerException());

      final container = createContainer();
      viewModelOf(container).updateUsername('mightymoses');
      await viewModelOf(container).submitForm();
      expect(stateOf(container).hasSubmitError, isTrue);

      when(
        () => repository.createUser(any()),
      ).thenAnswer((_) async => const User(username: 'mightymoses', id: '1'));

      expect(await viewModelOf(container).submitForm(), isTrue);
      expect(stateOf(container).hasSubmitError, isFalse);
    });
  });
}
