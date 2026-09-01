import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/theme/app_theme.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'package:zockblock_app/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ZockblockApp()));
}

/// Wurzel-Widget: verdrahtet Router, Lokalisierung und Theme.
class ZockblockApp extends ConsumerWidget {
  /// Erstellt die App.
  const ZockblockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
