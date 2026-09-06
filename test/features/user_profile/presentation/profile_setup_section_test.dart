import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/core/user/user_repository.dart';
import 'package:zockblock_app/core/user/user_repository_impl.dart';
import 'package:zockblock_app/features/user_profile/presentation/profile_setup_section.dart';

import '../../../helpers/pump_app.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late _MockUserRepository repository;

  setUpAll(() => registerFallbackValue(const User(username: 'fallback')));

  setUp(() {
    repository = _MockUserRepository();
    when(repository.getCurrentUser).thenAnswer((_) async => null);
  });

  Future<void> pumpSection(WidgetTester tester) {
    return tester.pumpApp(
      const ProfileSetupSection(),
      overrides: [userRepositoryProvider.overrideWithValue(repository)],
    );
  }

  testWidgets('zeigt vor dem Absenden keinen Fehler', (tester) async {
    await pumpSection(tester);

    // Ein Formular, das schon beim Öffnen meckert, ist unhöflich.
    expect(find.textContaining('Nutzernamen'), findsNothing);
  });

  testWidgets('meldet einen leeren Namen erst beim Absenden', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Erstellen'));
    await tester.pumpAndSettle();

    expect(find.text('Bitte gib einen Nutzernamen an.'), findsOneWidget);
    verifyNever(() => repository.createUser(any()));
  });

  testWidgets('nennt die Mindestlänge bei zu kurzem Namen', (tester) async {
    await pumpSection(tester);

    await tester.enterText(find.byType(TextField), 'ab');
    await tester.tap(find.widgetWithText(FilledButton, 'Erstellen'));
    await tester.pumpAndSettle();

    // Der Text kommt aus dem ARB und wird mit Username.minLength gefüllt.
    expect(find.textContaining('mindestens 3 Zeichen'), findsOneWidget);
  });

  testWidgets('zeigt einen Serverfehler an, statt still zu scheitern', (
    tester,
  ) async {
    when(
      () => repository.createUser(any()),
    ).thenAnswer((_) async => throw const ServerException());

    await pumpSection(tester);
    await tester.enterText(find.byType(TextField), 'mightymoses');
    await tester.tap(find.widgetWithText(FilledButton, 'Erstellen'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Profil konnte nicht angelegt werden'),
      findsOneWidget,
    );
  });

  testWidgets('legt bei gültiger Eingabe an und zeigt keinen Fehler', (
    tester,
  ) async {
    when(() => repository.createUser(any())).thenAnswer(
      (_) async => const User(username: 'mightymoses', id: '1'),
    );

    await pumpSection(tester);
    await tester.enterText(find.byType(TextField), 'mightymoses');
    await tester.tap(find.widgetWithText(FilledButton, 'Erstellen'));
    await tester.pumpAndSettle();

    verify(
      () => repository.createUser(const User(username: 'mightymoses')),
    ).called(1);
    expect(
      find.textContaining('Profil konnte nicht angelegt werden'),
      findsNothing,
    );
  });
}
