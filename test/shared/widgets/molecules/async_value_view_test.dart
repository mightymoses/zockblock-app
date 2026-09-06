import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/shared/widgets/molecules/async_value_view.dart';

import '../../../helpers/pump_app.dart';

/// Quelle, die sich im Test auf Fehler umschalten laesst.
class _Source {
  bool shouldFail = false;

  Future<String> load() async {
    if (shouldFail) throw const NetworkException();
    return 'Inhalt';
  }
}

final _sourceProvider = Provider<_Source>((ref) => _Source());

final AsyncNotifierProvider<_ValueNotifier, String> _valueProvider =
    AsyncNotifierProvider(_ValueNotifier.new);

class _ValueNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() => ref.watch(_sourceProvider).load();
}

/// Bindet [AsyncValueView] an [_valueProvider], damit die Zustandswechsel
/// echt entstehen statt von Hand zusammengesetzt zu werden.
class _Subject extends ConsumerWidget {
  const _Subject();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<String>(
      value: ref.watch(_valueProvider),
      data: Text.new,
    );
  }
}

void main() {
  Widget viewOf(AsyncValue<String> value, {VoidCallback? onRetry}) {
    return AsyncValueView<String>(
      value: value,
      onRetry: onRetry,
      data: Text.new,
    );
  }

  const failure = AsyncError<String>(NetworkException(), StackTrace.empty);

  testWidgets('zeigt den geladenen Wert', (tester) async {
    await tester.pumpApp(viewOf(const AsyncData('Inhalt')));

    expect(find.text('Inhalt'), findsOneWidget);
  });

  testWidgets('zeigt einen Ladeindikator, solange nichts da ist', (
    tester,
  ) async {
    await tester.pumpApp(viewOf(const AsyncLoading<String>()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('zeigt bei einem Fehler den passenden Text', (tester) async {
    await tester.pumpApp(viewOf(failure));

    // Kein Library-Fehlertext, sondern die uebersetzte Erklaerung.
    expect(find.textContaining('Keine Verbindung'), findsOneWidget);
  });

  testWidgets('ein vorhandener Wert bleibt bei Refresh und Fehler stehen', (
    tester,
  ) async {
    await tester.pumpApp(const _Subject());
    await tester.pumpAndSettle();
    expect(find.text('Inhalt'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_Subject)),
    );
    container.read(_sourceProvider).shouldFail = true;
    container.invalidate(_valueProvider);

    // Waehrend des Nachladens: kein Spinner anstelle des Inhalts, sonst
    // flackert die Seite bei jedem automatischen Retry.
    await tester.pump();
    expect(find.text('Inhalt'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Nach dem Fehlschlag: lieber veraltete Daten als eine Fehlermeldung
    // anstelle von Inhalt, den wir noch haben.
    await tester.pumpAndSettle();
    expect(find.text('Inhalt'), findsOneWidget);
    expect(find.textContaining('Keine Verbindung'), findsNothing);
  });

  group('Wiederholen', () {
    testWidgets('ohne onRetry gibt es keinen Button', (tester) async {
      await tester.pumpApp(viewOf(failure));

      expect(find.widgetWithText(TextButton, 'Erneut versuchen'), findsNothing);
    });

    testWidgets('mit onRetry loest der Button den Rueckruf aus', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpApp(viewOf(failure, onRetry: () => calls++));

      await tester.tap(find.widgetWithText(TextButton, 'Erneut versuchen'));

      expect(calls, 1);
    });
  });
}
