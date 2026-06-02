import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zockblock_app/l10n/app_localizations.dart';

void main() {
  runApp(const ZockblockApp());
}

class ZockblockApp extends StatelessWidget {
  const ZockblockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Placeholder(),
    );
  }
}