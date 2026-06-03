import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'package:zockblock_app/core/routing/app_router.dart';

void main() {
  runApp(const ZockblockApp());
}

class ZockblockApp extends StatelessWidget {
  const ZockblockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final materialTheme = MaterialTheme(Theme.of(context).textTheme);

        return MaterialApp.router(
          routerConfig: appRouter,
          title: 'Zockblock',
          // i18n
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de'),
            Locale('en'),
          ],
          // Theme
          theme: lightDynamic != null
              ? ThemeData(useMaterial3: true, colorScheme: lightDynamic)
              : materialTheme.light(),
          darkTheme: darkDynamic != null
              ? ThemeData(useMaterial3: true, colorScheme: darkDynamic)
              : materialTheme.dark(),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}