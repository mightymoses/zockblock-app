import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zockblock_app/core/auth/auth_repository.dart';
import 'package:zockblock_app/core/auth/auth_repository_impl.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';
import 'package:zockblock_app/core/consent/crash_report_consent_provider.dart';
import 'package:zockblock_app/core/user/user.dart';
import 'package:zockblock_app/core/user/user_repository.dart';
import 'package:zockblock_app/core/user/user_repository_impl.dart';
import 'package:zockblock_app/features/user_profile/presentation/user_profile_section.dart';

import '../../../helpers/pump_app.dart';

class _MockConsentStore extends Mock implements CrashReportConsentStore {}

class _MockUserRepository extends Mock implements UserRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockConsentStore store;
  late _MockUserRepository userRepository;
  late _MockAuthRepository authRepository;

  setUpAll(() => registerFallbackValue(CrashReportConsent.notAsked));

  setUp(() {
    store = _MockConsentStore();
    when(() => store.write(any())).thenAnswer((_) async {});

    userRepository = _MockUserRepository();
    when(userRepository.getCurrentUser).thenAnswer(
      (_) async => const User(username: 'mightymoses', id: '1'),
    );

    authRepository = _MockAuthRepository();
    when(authRepository.getExistingSession).thenAnswer((_) async => null);
  });

  Future<void> pumpSection(WidgetTester tester, CrashReportConsent stored) {
    when(store.read).thenAnswer((_) async => stored);

    return tester.pumpApp(
      const UserProfileSection(),
      overrides: [
        crashReportConsentStoreProvider.overrideWithValue(store),
        userRepositoryProvider.overrideWithValue(userRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
  }

  SwitchListTile switchOf(WidgetTester tester) =>
      tester.widget<SwitchListTile>(find.byType(SwitchListTile));

  testWidgets('spiegelt eine erteilte Einwilligung', (tester) async {
    await pumpSection(tester, CrashReportConsent.granted);
    await tester.pumpAndSettle();

    expect(switchOf(tester).value, isTrue);
  });

  testWidgets('spiegelt eine abgelehnte Einwilligung', (tester) async {
    await pumpSection(tester, CrashReportConsent.denied);
    await tester.pumpAndSettle();

    expect(switchOf(tester).value, isFalse);
  });

  testWidgets('Ausschalten widerruft und schreibt weg', (tester) async {
    // Der Widerruf ist verpflichtend - er muss tatsaechlich persistiert
    // werden, nicht nur den Schalter umlegen.
    await pumpSection(tester, CrashReportConsent.granted);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    verify(() => store.write(CrashReportConsent.denied)).called(1);
    expect(switchOf(tester).value, isFalse);
  });

  testWidgets('Einschalten erteilt die Einwilligung', (tester) async {
    await pumpSection(tester, CrashReportConsent.denied);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    verify(() => store.write(CrashReportConsent.granted)).called(1);
    expect(switchOf(tester).value, isTrue);
  });

  testWidgets('ist waehrend des Schreibens gesperrt', (tester) async {
    final pending = Completer<void>();
    when(() => store.write(any())).thenAnswer((_) => pending.future);

    await pumpSection(tester, CrashReportConsent.granted);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    // Verhindert, dass ein Doppeltipp zwei Schreibvorgaenge ausloest.
    expect(switchOf(tester).onChanged, isNull);

    pending.complete();
    await tester.pumpAndSettle();
    expect(switchOf(tester).onChanged, isNotNull);
  });
}
