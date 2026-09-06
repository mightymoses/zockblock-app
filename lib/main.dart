import 'dart:async';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/crash_reporting/crash_reporting_provider.dart';
import 'package:zockblock_app/core/error/retry_policy.dart';
import 'package:zockblock_app/core/logging/app_provider_observer.dart';
import 'package:zockblock_app/core/logging/logger_provider.dart';
import 'package:zockblock_app/core/theme/app_theme.dart';
import 'package:zockblock_app/firebase_options.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Fängt ab, was nicht durch Riverpod läuft: Fehler aus dem Widget-Baum und
  // unbehandelte asynchrone Fehler. Ob tatsächlich gesendet wird, entscheidet
  // allein die Einwilligung - siehe ZockblockApp.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
    );
    return true;
  };

  // Der Observer wird beim Bauen des Containers gebraucht, kann den Logger
  // also nicht aus ihm beziehen - daher einmal hier erzeugen und per Override
  // dieselbe Instanz auch in den Container geben.
  final logger = createAppLogger();

  runApp(
    ProviderScope(
      retry: appRetryPolicy,
      observers: [AppProviderObserver(logger)],
      overrides: [loggerProvider.overrideWithValue(logger)],
      child: const ZockblockApp(),
    ),
  );
}

/// Wurzel-Widget: verdrahtet Router, Lokalisierung und Theme.
class ZockblockApp extends ConsumerWidget {
  /// Erstellt die App.
  const ZockblockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hält die Crashlytics-Sammlung an der Einwilligung ausgerichtet: beim
    // Start am gespeicherten Wert, danach bei jeder Änderung - auch bei
    // einem Widerruf.
    ref.watch(crashReportingProvider);

    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final materialTheme = MaterialTheme(Theme.of(context).textTheme);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          title: 'Zockblock',
          // i18n
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de'), Locale('en')],
          // Theme
          theme: lightDynamic != null
              ? ThemeData(useMaterial3: true, colorScheme: lightDynamic)
              : materialTheme.light(),
          darkTheme: darkDynamic != null
              ? ThemeData(useMaterial3: true, colorScheme: darkDynamic)
              : materialTheme.dark(),
        );
      },
    );
  }
}
